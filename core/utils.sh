#!/bin/bash

OK=0
BAD=1

create_link()
{
	local -r SRC=$1
	local -r DST=$2

	if [ -L $DST ]; then
		echo "Remove symbolic link: $DST"
		rm -v $DST
	else
		mv -v $DST $DST.bak
	fi

	echo "Link $SRC to $DST"
	ln -sv $SRC $DST
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
	[[ -z "$SRC_PATH" ]] || echo $(pwd)/$SRC_PATH
}
