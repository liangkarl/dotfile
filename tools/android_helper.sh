#!/bin/bash

# Assume user has source envsetup.sh already
init-krnl-env() {
    local kernel_dir kernel_obj_dir
    local android_dir
    local gen_db_py compile_db

	[ -z "$ANDROID_PRODUCT_OUT" ] && {
		echo "No lunch config?" >&2
		return 128
	}

    kernel_dir="$1"
    [ ! -d "$kernel_dir" ] && {
        echo "invalid kernel dir path: $kernel_dir" >&2
        return 128
    }

    cd $kernel_dir
    kernel_dir=$(pwd)
    android_dir="$(dirname $kernel_dir)"
    kernel_obj_dir=${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ

    echo "linux kernel build out dir: $kernel_obj_dir"
    echo "linux kernel dir: $kernel_dir"
    echo "android dir: $android_dir"
    echo "-------------------------------------------------------------------"

    echo "Link build dir."
    ln -svf $kernel_obj_dir build
    cd - &> /dev/null

    gen_db_py=gen_compile_commands.py
    for dir in "$(pwd)" "$kernel_dir/scripts" "$android_dir" "$SHELL_DIR/tools"; do
        [ -e $dir/$gen_db_py ] && {
            gen_db_py=$dir/$gen_db_py
            break
        }
    done

    [ ! -e $gen_db_py ] && {
        echo "no $gen_db_py to continue" >&2
        return 128
    }

    cp $gen_db_py $kernel_obj_dir
    gen_db_py=$(basename $gen_db_py)

    compile_db=compile_commands.json
    cd $kernel_obj_dir
    echo "generate compile commands db..."
    chmod +x $gen_db_py
    ./$gen_db_py

    echo "replace file pathes"
    sed -i "s|$kernel_obj_dir|$kernel_dir|g" $compile_db
    sed -i 's/[ \t]*$//g' $compile_db

    echo "copy commands db to $kernel_dir/$compile_db"
    cp -f $compile_db $kernel_dir
    cd - &> /dev/null
}
