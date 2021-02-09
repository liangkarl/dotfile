#!/bin/bash

__help_mtk_make() {
    cat << USAGE
SYNOPSIS:
$1 [-k|k|kernel] [-v|v|vendor] [-s|s|system] [-m|m|merge]
$1 [-ak|ak|add-kernel] [-av|av|add-vendor] [-as|as|add-system]
$1 [-l|l|list]

DESCRIPTION:
$1 is a helper script of MTK make.
The script would save your lastest lunch configs of sys, krnl
and vndr if you keep using these commands.
USAGE
}

mtk-make() {
	local MAKE_CMD MERGE_CMD CLEAN_CMD
	local SPLIT_BUILD MERGED_OUT_DIR

    [ $# -eq 0 ] && {
            __help_mtk_make $FUNCNAME
            return 1
    }

	[ -z $ANDROID_PRODUCT_OUT ] && {
		echo "No lunch config?" >&2
		return 128
	}

    for ARGV in "$@"; do
		case "$ARGV" in
            ak|-ak|add-kernel)
				MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT
                echo "kernel lunch added: $MTK_MAKE_KERNEL_OUT_DIR"
                ;;
            av|-av|add-vendor)
				MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT
                echo "vendor lunch added: $MTK_MAKE_VENDOR_OUT_DIR"
                ;;
            as|-as|add-system)
				MTK_MAKE_SYSTEM_OUT_DIR=$ANDROID_PRODUCT_OUT
                echo "system lunch added: $MTK_MAKE_SYSTEM_OUT_DIR"
                ;;
			k|-k|kernel)
				MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="krn_images "
				CLEAN_CMD+="rm -rf $MTK_MAKE_KERNEL_OUT_DIR/obj/KERNEL_OBJ;"
				;;
			s|-s|system)
				MTK_MAKE_SYSTEM_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="sys_images "
				CLEAN_CMD+="rm -rf $MTK_MAKE_SYSTEM_OUT_DIR/obj;"
				;;
			v|-v|vendor)
				MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="vnd_images "
				;;
			kv|-kv|vk|-vk)
				MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT
				MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="vnd_images krn_images "
				CLEAN_CMD+="rm -rf $MTK_MAKE_KERNEL_OUT_DIR/obj/KERNEL_OBJ;"
				;;
			m|-m|merge)
				SPLIT_BUILD=$MTK_MAKE_SYSTEM_OUT_DIR/images/split_build.py
				MERGED_OUT_DIR=$MTK_MAKE_KERNEL_OUT_DIR/merged
				echo "========================================="
				echo "Make sure these pathes are correct or not"
				echo "split_build: $SPLIT_BUILD"
				echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
				echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
				echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
				echo "out: $MERGED_OUT_DIR"
				echo "========================================="
				MERGE_CMD="python $SPLIT_BUILD "
                MERGE_CMD+="--system-dir $MTK_MAKE_SYSTEM_OUT_DIR/images "
                MERGE_CMD+="--vendor-dir $MTK_MAKE_VENDOR_OUT_DIR/images "
                MERGE_CMD+="--kernel-dir $MTK_MAKE_KERNEL_OUT_DIR/images "
                MERGE_CMD+="--output-dir $MERGED_OUT_DIR"
				CLEAN_CMD+="rm -rf $MERGED_OUT_DIR;"
				;;
			c*|-c*|clean)
				echo "-c | -c *) not support yet"
				echo "TODO: for clean purpose"
                return 0;
				;;
            l|-l|list)
                echo "list out dir:"
                echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
                echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
                echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
                return 0;
                ;;
			*)
                __help_mtk_make $FUNCNAME
				return 128
		esac
	done

    [ -z "$MAKE_CMD" ] || MAKE_CMD="make -j24 $MAKE_CMD"

    for CMD in "$CLEAN_CMD" "$MAKE_CMD" "$MERGE_CMD"; do
        [ -z "$CMD" ] && continue
        echo "$CMD"
        $CMD || return $?
    done
	return 0;
}
