#!/bin/bash

# Assume user has source envsetup.sh already
init-krnl-env() {
    local KERNEL_DIR KERNEL_OBJ_DIR
    local ANDROID_DIR
    local GEN_DB_PY COMPILE_DB

	[ -z $ANDROID_PRODUCT_OUT ] && {
		echo "No lunch config?" >&2
		return 128
	}

    KERNEL_DIR="$1"
    [ -z "$KERNEL_DIR" ] && {
        echo "Where is kernel dir?" >&2
        return 128
    }

    cd $KERNEL_DIR
    KERNEL_DIR=$(pwd)
    ANDROID_DIR="$(dirname $KERNEL_DIR)"

    echo "Linux kernel build out dir: $KERNEL_OBJ_DIR"
    echo "Linux kernel dir: $KERNEL_DIR"
    echo "Android dir: $ANDROID_DIR"
    echo "-------------------------------------------------------------------"

    KERNEL_OBJ_DIR=${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ
    echo "Link build dir."
    ln -svf $KERNEL_OBJ_DIR build
    cd - &> /dev/null

    GEN_DB_PY=gen_compile_commands.py
    for DIR in "." "$KERNEL_DIR/scripts" "$ANDROID_DIR"; do
        [ -e $DIR/$GEN_DB_PY ] && {
            GEN_DB_PY=$DIR/$GEN_DB_PY
            break
        }
    done

    [ ! -e $GEN_DB_PY ] && {
        echo "No $GEN_DB_PY to continue" >&2
        return 128
    }

    cp $GEN_DB_PY $KERNEL_OBJ_DIR
    GEN_DB_PY=$(basename $GEN_DB_PY)

    COMPILE_DB=compile_commands.json
    cd $KERNEL_OBJ_DIR
    echo "Generate compile commands DB..."
    chmod +x $GEN_DB_PY
    ./$GEN_DB_PY

    echo "Replace file pathes"
    sed -i "s|$KERNEL_OBJ_DIR|$KERNEL_DIR|g" $COMPILE_DB
    sed -i 's/[ \t]*$//g' $COMPILE_DB

    echo "Copy commands DB to $KERNEL_DIR/$COMPILE_DB"
    cp -f $COMPILE_DB $KERNEL_DIR
    cd - &> /dev/null
}
