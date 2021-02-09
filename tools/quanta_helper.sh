#!/bin/bash

__to_vm_path() {
	local SRC FINAL
	SRC="$1"

	[ -z "$SRC" ] && return
	FINAL="$(echo $SRC | sed "s|^$HOME|\0/vm|")"

	echo "$FINAL"
}

__rsync_cmd() {
	local SRC DST
	SRC="$1"
	DST="${2:-.}"

	echo "SRC: $SRC"
	echo "DST: $DST"
	echo "================================"

	rsync -hav -r $SRC $DST
}

from_saturn() {
	local SRVR DST SRC
	SRVR='saturn'
	SRC=$(__to_vm_path "$1")
	DST="${2:-files@$(date +%s)}"

	[ $# -eq 0 ] && {
		declare -f $FUNCNAME
		return 1
	}

	__rsync_cmd $SRVR:$SRC $DST
}

to_saturn() {
	local DST SRVR SRC
	SRVR='saturn'
	SRC="$1"
	DST=$(__to_vm_path "$2")

	[ $# -eq 0 ] && {
		declare -f $FUNCNAME
		return 1
	}

	[ -z $DST ] && {
		echo "Copy to where?"
		return 1
	}
	__rsync_cmd $SRC $SRVR:$DST
}

from_hogwarts() {
	local SRVR DST SRC
	SRVR='hogwarts'
	SRC=$(__to_vm_path "$1")
	DST="${2:-files@$(date +%s)}"

	[ $# -eq 0 ] && {
		declare -f $FUNCNAME
		return 1
	}

	__rsync_cmd $SRVR:$SRC $DST
}

to_hogwarts() {
	local DST SRVR SRC
	SRVR='hogwarts'
	SRC="$1"
	DST=$(__to_vm_path "$2")

	[ $# -eq 0 ] && {
		declare -f $FUNCNAME
		return 1
	}

	[ -z $DST ] && {
		echo "Copy to where?"
		return 1
	}
	__rsync_cmd $SRC $SRVR:$DST
}

setup_vpn() {
	local FILE
	FILE="$HOME/.config/openvpn/client.ovpn"

	if [ ! -e $FILE ]; then
		echo "not support yet"
		# copy file
	fi

	alias vpn-on='sudo openvpn $HOME/.config/openvpn/client.ovpn'
}

alias pwr='set +f; __exe_by_powershell '; __exe_by_powershell() {
	powershell.exe -c "$@"
	set -f
}

mtk_make() {
	[ -z $ANDROID_PRODUCT_OUT ] && {
		echo "No lunch config?" >&2
		return 128
	}

	local MAKE_CMD MERGE_CMD CLEAN_CMD
	local SPLIT_BUILD MERGED_OUT_DIR

	MAKE_CMD='make -j24 '
	while :; do
		case "$1" in
			k | -k)
				MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="krn_images "
				CLEAN_CMD+="rm -rf $MTK_MAKE_KERNEL_OUT_DIR/obj/KERNEL_OBJ;"
				;;
			s | -s)
				MTK_MAKE_SYSTEM_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="sys_images "
				;;
			v | -v)
				MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="vnd_images "
				;;
			kv | -kv | vk | -vk)
				MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT
				MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT
				MAKE_CMD+="vnd_images krn_images "
				;;
			m | -m)
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
				MERGE_CMD="python $SPLIT_BUILD --system-dir $MTK_MAKE_SYSTEM_OUT_DIR/images
					--vendor-dir $MTK_MAKE_VENDOR_OUT_DIR/images
					--kernel-dir $MTK_MAKE_KERNEL_OUT_DIR/images
					--output-dir $MERGED_OUT_DIR"
				CLEAN_CMD+="rm -rf $MERGED_OUT_DIR;"
				;;
			c* | -c*)
				echo "-c | -c *) not support yet"
				echo "TODO: for clean purpose"
				;;
			*)
				echo "========================================="
				echo "Check usages as below"
				echo "========================================="
				declare -f mtk_make
				return 128
		esac
		shift
	done

	$CLEAN_CMD
	$MAKE_CMD
	$MERGE_CMD

	return 0;
}

make_kernel() {
	declare -f $FUNCNAME

	[ -z "$TARGET_PRODUCT" ] && {
		echo "no lunch config"
			return 1
		}

	echo "================"
	echo "  kernel image  "
	echo "================"
	local RET
	rm -rf out/target/product/qbert/obj/KERNEL_OBJ/
	make -j24 krn_images
	RET=$?
	[ $RET -eq 0 ] || return 1

	echo "================"
	echo "   merge image  "
	echo "================"
	rm -rf out/target/product/qbert/merged
	python out/target/product/mssi_t_64_ab/images/split_build.py --system-dir out/target/product/mssi_t_64_ab/images --vendor-dir out/target/product/qbert/images --kernel-dir out/target/product/qbert/images --output-dir out/target/product/qbert/merged
}
