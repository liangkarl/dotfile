#!/bin/bash

OK=0
BAD=1

create_link()
{
	local -r SRC=$1
	local -r DST=$2

	echo "Link $SRC to $DST"
	ln -svib $SRC $DST
}

test_cmd()
{
	command -v >&- "$@" && \
		return $OK || \
		return $BAD
}

setup_version()
{
	local -r LINK=$1
	local -r NAME=$2
	# Seperated by " "
	local -r LIST=$3
	local PRIORITY=10
	for LOCATION in $LIST; do
		sudo update-alternatives --install $LINK $NAME $LOCATION $PRIORITY
		PRIORITY=$((PRIORITY + 10))
	done
	sudo update-alternatives --config $NAME
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
