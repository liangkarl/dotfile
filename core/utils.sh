#!/bin/bash

OK=0
BAD=1

create_link()
{
        local -r SRC=$1
        local -r DST=$2

        if [ -e $DST ] && [ ! -L $DST ]; then
                echo "Move $DST to $DST.bak"
                mv $DST $DST.bak
        elif [ -L $DST ]; then
                echo "Remove symbolic link: $DST"
                rm $DST
        fi

        echo "Link $SRC to $DST"
        ln -s $SRC $DST
}

test_cmd()
{
        command -v >&- "$@" && \
                return $OK || \ 
                return $BAD
}

is_abs_path()
{
        local -r TEST_PATH=$1
        [[ "$TEST_PATH" = /* ]] && 
                return $OK ||
                return $BAD
}

to_abs_path()
{
        local -r SRC_PATH=$1
        [ "$SRC_PATH" -z ] || echo $(pwd)/$1
}
