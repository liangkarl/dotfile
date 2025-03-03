#!/usr/bin/env bash

path.uniq() {
    path.abs "$*"
}

path.abs() {
    realpath -m -s "$@" || \
        grealpath -m -s "$@"
} 2>&-

path.rel() {
    realpath -m -s --relative-to=$(pwd) "$@" || \
        grealpath -m -s --relative-to=$(pwd) "$@"
} 2>&-

# call the func to get the file path inside the sourced script
path.in_source() {
    readlink -e "$(dirname ${BASH_SOURCE[0]})" || \
        greadlink -e "$(dirname ${BASH_SOURCE[0]})"
} 2>&-

# usage:
# path.load FILE
path.load() {
    local path name

    name="$(basename $1)"
    path="$(dirname $1)"
    [[ -z "$path" ]] && path=$(pwd)
    path="$(path.abs $path)"

    while [[ ! -e ${path}/$name ]]; do
        [[ -z "${path}" ]] && return 1
        path="${path%/*}"
    done

    echo ${path}/$name
}

source.load() {
    source $(path.load $* || echo "$*")
}

msg.err() {
    echo "$*" >&2
    false
}

msg.exit() {
    local r stderr
    r=$1; shift
    [[ "$r" -ne 0 ]] && stderr=">&2"
    eval "echo "$*" ${stderr}"
    exit $r
}

msg.dbg() {
    echo "$*" 2>/dev/null >&87
}

# Load the help information on the top of the file
# These information is written in normal bash comments format
# and stop with single empty line.
msg.help() {
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
    local $1
}

dbg.file() {
    [[ -z "$1" ]] && return 1
    __DBG_FD="$1"
}

dbg.on() {
    [[ -n "$__DBG_FD" ]] && exec &> >(tee $__DBG_FD)
    exec 87>&1
}

# XXX:
# should place dbg.off in the end of the file
# side effect:
# 1. the debug file could not be disabled
dbg.off() {
    if [[ -n "$__DBG_FD" ]]; then
        unset __DBG_FD
    fi
    exec 87>&-
}

sys.has_cmd() {
    type -t "$1" &> /dev/null
}

# Check
is_uint() { case $1        in '' | *[!0-9]*              ) return 1;; esac ;}
is_int()  { case ${1#[-+]} in '' | *[!0-9]*              ) return 1;; esac ;}
is_unum() { case $1        in '' | . | *[!0-9.]* | *.*.* ) return 1;; esac ;}
is_num()  { case ${1#[-+]} in '' | . | *[!0-9.]* | *.*.* ) return 1;; esac ;}
is_hex()  { ((16#$1)) &> /dev/null || return 1; }

# chk_ver [min-ver] [cur-ver]
# return 0 if current ver >= min ver.
vercmp() {
    [  "$1" = "$(printf -- "$1\n$2\n" | sort -V | head -n1)" ]
}

dump_stack() {
    local TRACE=""
    local CP=${1:-$$} # PID of the script itself [1]

    while true # safe because "all starts with init..."
    do
        CMDLINE=$(cat /proc/$CP/cmdline)
        PP=$(grep PPid /proc/$CP/status | awk '{ print $2; }') # [2]
        TRACE="$TRACE [$CP]:$CMDLINE\n"
        if [ "$CP" == "1" ]; then # we reach 'init' [PID 1] => backtrace end
            break
        fi
        CP=$PP
    done
    echo "Backtrace of '$0'"
    echo -en "$TRACE" | tac | grep -n ":" # using tac to "print in reverse" [3]
}

# pause [ret]
pause() {
    read -p "Press ENTER to continue."
    return $1
}
