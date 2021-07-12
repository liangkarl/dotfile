#!/bin/bash

# MIT License
# -----------
# Copyright (c) 2021 Karl Liang
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

. lunch.list

MTK_KERNEL_LUNCH=${kernel_lunch:-vnd_qbert-userdebug}
MTK_VENDOR_LUNCH=${vendor_lunch:-vnd_qbert-userdebug}
MTK_SYSTEM_LUNCH=${sys_lunch:-sys_mssi_t_64_ab_p-userdebug}

__help_mtk_make() {
    cat << USAGE
NAME:

    $1 - a helper script for MTK build system.

SYNOPSIS:

    $1 [-k|k|kernel] [-v|v|vendor] [-s|s|system]
    $1 [-m|m|merge] [-mo|mo|merge-ota]
    $1 [-ak|ak|add-kernel config] [-av|av|add-vendor config] [-as|as|add-system config]
    $1 [-l|l|list]

DESCRIPTION:

    k, v, s - compile kernel, vendor or system

    m - execute MTK sign script to generate whole images for flash tool

    ak, av, as - add lunch config of kernel, vendor or system, this option wouldn't
                 lunch config actually, only recording the config name. These lunch
                 configs would be activated when 'k' 'v' or 's' options is added.

    l - list current config and output dir location. Output dir only appreared after
        compile source codes.

EXAMPLE:

    $ $1 ak vnd_qbert-userdebug     # add kernel config
    $ $1 l          # show config and output info
    $ $1 k v s m    # compile kernel, vendor, system and merge images

USAGE
}

__mtk_make_merge() {
    local split_build merged_dir
    local argv cmd

    if [ "$MTK_MAKE_KERNEL_OUT_DIR" == "" ]; then
        lunch $MTK_KERNEL_LUNCH || return $?
    fi
    if [ "$MTK_MAKE_VENDOR_OUT_DIR" == "" ]; then
        lunch $MTK_VENDOR_LUNCH || return $?
    fi
    if [ "$MTK_MAKE_SYSTEM_OUT_DIR" == "" ]; then
        lunch $MTK_SYSTEM_LUNCH || return $?
    fi

    argv="$1"
    merged_dir="$(readlink -f final-images)"
    split_build=$MTK_MAKE_SYSTEM_OUT_DIR/images/split_build.py

    echo "========================================="
    echo "Make sure these pathes are correct"
    echo "split_build: $split_build"
    echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
    echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
    echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
    echo "out: $merged_dir"
    echo "========================================="

    rm -rf $merged_dir
    cmd="python $split_build"
    cmd+=" --system-dir $MTK_MAKE_SYSTEM_OUT_DIR/images"
    cmd+=" --vendor-dir $MTK_MAKE_VENDOR_OUT_DIR/images"
    cmd+=" --kernel-dir $MTK_MAKE_KERNEL_OUT_DIR/images"
    cmd+=" --output-dir $merged_dir"
    cmd+=" ${argv}"

    eval $cmd
    return $?
}

__mtk_make_exe_cmds() {
    local cmd_list
    local cmd ret i

    cmd_list=("$@")
    ret=0
    for((i = 0; i < ${#cmd_list[@]}; i++)); do
        cmd=${cmd_list[$i]}
        echo "$cmd"
        eval $cmd || {
            ret=$?
            echo "failed at: $cmd" >&2
            break
        }
    done

    return $ret
}

__mtk_make_cmd_hub() {
    local cmd_list

    cmd_list=()
    argv="$1"
    case "$argv" in
        k|-k|kernel)
            cmd_list+=("lunch $MTK_KERNEL_LUNCH")
            cmd_list+=('MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT')
            cmd_list+=("rm -rf $MTK_MAKE_KERNEL_OUT_DIR/obj/KERNEL_OBJ")
            cmd_list+=("rm -rf $MTK_MAKE_KERNEL_OUT_DIR/images/krn*")
            cmd_list+=("make -j24 krn_images")
            ;;
        s|-s|system)
            cmd_list+=("lunch $MTK_SYSTEM_LUNCH")
            cmd_list+=('MTK_MAKE_SYSTEM_OUT_DIR=$ANDROID_PRODUCT_OUT')
            cmd_list+=("rm -rf $MTK_MAKE_SYSTEM_OUT_DIR/obj")
            cmd_list+=("rm -rf $MTK_MAKE_SYSTEM_OUT_DIR/images")
            cmd_list+=("make -j24 sys_images")
            ;;
        v|-v|vendor)
            cmd_list+=("lunch $MTK_VENDOR_LUNCH")
            cmd_list+=('MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT')
            # avoid to remove kernel obj with same config name
            cmd_list+=("rm -rf $MTK_MAKE_VENDOR_OUT_DIR/obj/[!KERNEL_OBJ]")
            cmd_list+=("rm -rf $MTK_MAKE_VENDOR_OUT_DIR/images/vnd*")
            cmd_list+=("make -j24 vnd_images")
            ;;
    esac

    __mtk_make_exe_cmds "${cmd_list[@]}" || return $?
}

# Assume user has sourced envsetup.sh
mtk-make() {
    local cmd_list
    local argv
    local -i timer

    (( $# == 0 )) && {
        __help_mtk_make $FUNCNAME
        return 1
    }

    cmd_list=()
    while (( $# != 0 )); do
        argv="$1"
        case "$argv" in
            ak|-ak|add-kernel)
                shift
                MTK_KERNEL_LUNCH="$1"
                MTK_MAKE_KERNEL_OUT_DIR=''
                echo "kernel lunch added: $MTK_KERNEL_LUNCH"
                ;;
            av|-av|add-vendor)
                shift
                MTK_VENDOR_LUNCH="$1"
                MTK_MAKE_VENDOR_OUT_DIR=''
                echo "vendor lunch added: $MTK_VENDOR_LUNCH"
                ;;
            as|-as|add-system)
                shift
                MTK_SYSTEM_LUNCH="$1"
                MTK_MAKE_SYSTEM_OUT_DIR=''
                echo "system lunch added: $MTK_SYSTEM_LUNCH"
                ;;
            k|-k|kernel|\
            s|-s|system|\
            v|-v|vendor)
                cmd_list+=("__mtk_make_cmd_hub $argv")
                ;;
            m|-m|merge)
                cmd_list+=("__mtk_make_merge")
                ;;
            o|-o|ota)
                cmd_list+=("__mtk_make_merge --otapackage")
                ;;
            l|-l|list)
                echo "List lunch config:"
                echo "kernel: $MTK_KERNEL_LUNCH"
                echo "vendor: $MTK_VENDOR_LUNCH"
                echo "system: $MTK_SYSTEM_LUNCH"
                echo "List out dir:"
                echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
                echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
                echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
                return 0
                ;;
            *)
                __help_mtk_make $FUNCNAME
                return 128
        esac
        shift
    done

    timer=$(date +%s)
    __mtk_make_exe_cmds "${cmd_list[@]}" || return $?
    timer="$(date +%s)-$timer"
    echo "total comsumed time: $(date -d@$((timer)) -u +%H:%M:%S)"

    return 0;
}

if [ -f build/envsetup.sh ]; then
    . build/envsetup.sh
fi
complete -F _lunch mtk-make
