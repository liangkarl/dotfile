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

qhint() {
    local INPUT CMD STR

    [[ $# == 0 ]] && {
        echo "$FUNCNAME dir/file"
        return 1
    }

    INPUT="$1"
    [ ! -e $INPUT ] && {
        echo "No exist: $INPUT"
        return 128
    }

    if [ -d $INPUT ]; then
        INPUT=$(cd $INPUT; pwd)
    else
        INPUT=$(cd $(dirname $INPUT); pwd)/$(basename $INPUT)
    fi

    CMD='qsync'
    STR='paste_here'
    echo "Note: Manually add options by yourself, like -r for dir"
    echo "Copy from:"
    echo "$CMD   $HOSTNAME:$INPUT   $STR"
    echo ""
    echo "Copy to:"
    echo "$CMD   $STR   $HOSTNAME:$INPUT"
    return 0
}

# quanta sync
qsync() {
    local HOST SRC LOC DST ARGS
    local RET

    [[ $# < 2 ]] && {
        echo "$FUNCNAME HOST:SRC DST"
        echo "$FUNCNAME SRC... HOST:DST"
        return 128
    }

    # TODO: parse different user here
    SRC=()
    while [ $# -ne 1 ]; do
        if [[ "$1" == "-"* ]]; then
            ARGS+=" $1"
        elif [[ "$1" == *":"* ]]; then
            HOST="${1%:*}"
            LOC="${1##*:}"
            LOC="$(__to_vm_path $LOC)"
            SRC+=("$HOST:$LOC")
        else
            SRC+=("$1")
        fi
        shift
    done

    if [[ "$1" == *":"* ]]; then
        HOST="${1%:*}"
        LOC="${1##*:}"
        LOC="$(__to_vm_path $LOC)"
        DST="$HOST:$LOC"
    else
        DST="$1"
    fi

    rsync -hav $ARGS "${SRC[@]}" $DST
    RET=$?

    echo "================================"
    echo "SRC: ${SRC[@]}"
    echo "DST: $DST"
    return $RET
}
complete -F _rsync -o nospace qsync

add-template() {
    [[ $# == 0 ]] && {
        declare -f $FUNCNAME
        return
    }
    git config commit.template $@
}

dir-size() {
    [[ $# == 0 ]] && {
        declare -f $FUNCNAME
        return
    }
    du -sh $@
}

# Only customized for pobu vm clients
disk-usage() {
    [[ $# > 0 ]] && echo "warn: no need for input args"
    df -Thx tmpfs
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
