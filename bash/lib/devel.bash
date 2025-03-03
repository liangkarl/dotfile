#!/usr/bin/env bash

__DEVEL_BASH_FUNCS_BEFORE=$(declare -F | awk '{print $3}')

# check cmd
cmd.has() {
    type -t "$1" &> /dev/null
}

# it would run the CMDx and return it once CMDx successfully executed
# cmd.get_result [CMD1] [CMD2] [...]
cmd.try() {
    local cmd

    for cmd in "$@"; do
        eval "$cmd" && return
    done 2> /dev/null

    return $#
}

path.uniq() {
    path.abs "$*"
}

path.abs() {
    cmd.try "realpath -m -s '$*'" \
            "grealpath -m -s '$*'"
}

path.rel() {
    cmd.try "realpath -m -s --relative-to=$(pwd) '$*'" \
            "grealpath -m -s --relative-to=$(pwd) '$*'"
}

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

source.dir() {
    eval "$(find $1 -type f -exec 'echo' 'source' '{};' ';' | sort)"
}

# call the func to get the file path inside the sourced script
source.path() {
    path.abs "${BASH_SOURCE[1]}"
}

source.dirname() {
    source.path | xargs dirname
} 2> /dev/null

source.name() {
    basename "${BASH_SOURCE[1]}"
} 2> /dev/null

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

# Check
is_uint() { case $1        in '' | *[!0-9]*              ) return 1;; esac ;}
is_int()  { case ${1#[-+]} in '' | *[!0-9]*              ) return 1;; esac ;}
is_unum() { case $1        in '' | . | *[!0-9.]* | *.*.* ) return 1;; esac ;}
is_num()  { case ${1#[-+]} in '' | . | *[!0-9.]* | *.*.* ) return 1;; esac ;}
is_hex()  { ((16#$1)) &> /dev/null || return 1; }

# cmd.chkver CUR_VER MIN_VER
# return 0 if current ver >= min ver.
cmd.chkver() {
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

devel.clean() {
    local f
    for f in $__DEVEL_BASH_FUNCS_DIFF; do
        unset -f "$f"
    done
    unset __DEVEL_BASH_FUNCS_DIFF
}

devel.export() {
    local f
    for f in $__DEVEL_BASH_FUNCS_DIFF; do
        export -f $f
    done
}

__DEVEL_BASH_FUNCS_AFTER=$(declare -F | awk '{print $3}')

if [[ -n "$__DEVEL_BASH_FUNCS_DIFF" ]]; then
    msg.dbg "$(source.name): use old diff table"
else
    # time __DEVEL_BASH_FUNCS_DIFF=$(comm -23 <(printf "%s\n" $' '"$__DEVEL_BASH_FUNCS_AFTER" | sort) <(printf "%s\n" $' '"$__DEVEL_BASH_FUNCS_BEFORE" | sort))
    # time __DEVEL_BASH_FUNCS_DIFF=$(printf "%s\n" $__DEVEL_BASH_FUNCS_AFTER | grep -Fvx -f <(printf "%s\n" $__DEVEL_BASH_FUNCS_BEFORE))
    __DEVEL_BASH_FUNCS_DIFF=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__DEVEL_BASH_FUNCS_BEFORE) <(printf "%s\n" $__DEVEL_BASH_FUNCS_AFTER))
fi
unset __DEVEL_BASH_FUNCS_AFTER __DEVEL_BASH_FUNCS_BEFORE
