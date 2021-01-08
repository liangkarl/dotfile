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

add_ppa_repo()
{
	local -r NAME=$1
	test_cmd add-apt-repository || sudo apt install software-properties-common
	sudo add-apt-repository $NAME
	sudo apt update
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
