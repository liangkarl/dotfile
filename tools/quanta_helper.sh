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

	__rsync_cmd $SRVR:$SRC $DST
}

to_saturn() {
	local DST SRVR SRC
	SRVR='saturn'
	SRC="$1"
	DST=$(__to_vm_path "$2")

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

	__rsync_cmd $SRVR:$SRC $DST
}

to_hogwarts() {
	local DST SRVR SRC
	SRVR='hogwarts'
	SRC="$1"
	DST=$(__to_vm_path "$2")

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
