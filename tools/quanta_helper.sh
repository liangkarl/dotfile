#!/bin/bash

__to_vm_path() {
	local SRC FINAL
	SRC="$1"

	[ -z "$SRC" ] && return

    if [[ "$SRC" == ~* ]]; then
        FINAL="$(echo $SRC | sed "s|^~|$HOME/vm|")"
    else
	    FINAL="$(echo $SRC | sed "s|^$HOME|\0/vm|")"
    fi

	echo "$FINAL"
}

# quanta sync
qsync() {
    local HOST SRC DST
    local DIRECT RET

    [ $# -le 2 ] && {
        echo "$FUNCNAME HOST:SRC DST"
        echo "$FUNCNAME SRC... HOST:DST"
        return 128
    }

    # TODO: parse different user here
    SRC=()
    while [ $# -ne 1 ]; do
        if [[ "$1" == *":"* ]]; then
            HOST="${1%:*}"
            SRC="${1##*:}"
            SRC=$(__to_vm_path $SRC)
            DIRECT='in'
        else
            SRC+=("$1")
        fi
        shift
    done

    if [[ "$1" == *":"* ]]; then
        HOST="${1%:*}"
        DST="${1##*:}"
        DST="$(__to_vm_path $DST)"
        DIRECT='out'
    else
        DST="$1"
    fi

    if [ "$DIRECT" == 'in' ]; then
        __rsync_cmd $HOST:$SRC $DST
        rsync -hav -r $SRC $DST
    else
        rsync -hav -r "${SRC[@]}" $HOST:$DST
    fi
    RET=$?

    echo "================================"
    echo "SRC: ${SRC[@]}"
    echo "DST: $DST"
    return $RET
}
complete -F _rsync -o nospace qsync

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
