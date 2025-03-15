#!/usr/bin/env bash

[[ -v __DEVEL_BASH_INCLUDED ]] && return

__DEVEL_BASH_BEFORE="$(compgen -A function) $(compgen -v)"

__N=/dev/null
__DBG_ALL='__global__'

__dbg_fd() {
    echo $((87 + $1))
}

# check cmd
cmd.has() {
    type -t "$1" &> $__N
}

# it would run the CMDx and return it once CMDx successfully executed
# cmd.get_result [CMD1] [CMD2] [...]
cmd.try() {
    local cmd

    for cmd in "$@"; do
        eval "$cmd" && return
    done 2> $__N

    return $#
}

# Load the help information on the top of the file
# These information is written in normal bash comments format
# and stop with single empty line.
# - The keyword $0 would be replaced with file name
cmd.help() {
    sed -ne "/^#/!q; s/\$0/$(basename $0)/g; s/.\{1,2\}//; 1d; p" < "$0"
    exit $1
}

# cmd.chkver CUR_VER MIN_VER
# return 0 if current ver >= min ver.
cmd.chkver() {
    [  "$1" = "$(printf -- "$1\n$2\n" | sort -V | head -n1)" ]
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
} 2> $__N

source.name() {
    basename "${BASH_SOURCE[1]}"
} 2> $__N

msg.err() {
    msg "ERROR: $*" >&2
}

msg.warn() {
    msg " WARN: $*" >&2
}

msg.info() {
    msg " INFO: $*"
}

msg() {
    printf -- "$@\n"
}

# only support file-based space since bash could not tell who call msg.dbg
# until the file name was given
msg.dbg() {
    local offset idx id

    # don't use source.name since it would return devel.sh while using this
    # function in other scripts
    eval "id=\$(basename \${BASH_SOURCE[${__DBG_IDX:-1}]})"
    # echo "stack=${BASH_SOURCE[@]}"
    # echo "id: $id"
    offset=$(list.index_of __DEVEL_BASH_DBG_SPACE_LIST $id)
    if [[ -z "$offset" ]]; then
        offset=$(list.index_of __DEVEL_BASH_DBG_SPACE_LIST ${__DBG_ALL})
        [[ -z "$offset" ]] && return
    fi

    idx=$(list.index_of __DEVEL_BASH_CUR_SPACE_LIST $offset)
    [[ -z "$idx" ]] && return

    msg "DEBUG: ${id}: $*" 2>${__N} >&$(__dbg_fd $offset)
}

msg.exit() {
    local r

    r=$1; shift
    if [[ "$r" -ne 0 ]]; then
        msg.err "$*"
    else
        msg.info "$*"
    fi
    exit $r
}

# list.index_of LIST VALUE
list.index_of() {
    [[ $# -lt 2 ]] && return
    eval "echo \"\$(printf \"%s\\n\" \"\${$1[@]}\" | awk -v val=\"$2\" '{if (\$0 == val) print NR-1}')\""
}

# list.insert LIST VALUE [KEY]
# default append to the last element
list.insert() {
    [[ $# -lt 2 ]] && return
    eval "local k=\${3:-\${#$1[@]}}"
    eval "$1=(\"\${$1[@]:0:$k}\" \"$2\" \"\${$1[@]:$k}\")"
}

# list.remove LIST [KEY]
# default remove the last element
list.remove() {
    [[ $# -lt 1 ]] && return
    eval "local k=\${2:-\$((\${#$1[@]}-1))}"
    eval "unset '$1[$k]'"
    eval "$1=(\"\${$1[@]}\")"
}

# list.has LIST VALUE
list.has() {
    [[ $# -lt 2 ]] && return 1
    [[ -z "$(list.index_of \"$1\" \"$2\")" ]] &> $__N
}

# declare -a __DEVEL_BASH_DBG_SPACE
__DEVEL_BASH_CUR_SPACE_LIST=(${__DEVEL_BASH_CUR_SPACE_LIST[@]})
__DEVEL_BASH_DBG_SPACE_LIST=(${__DEVEL_BASH_DBG_SPACE_LIST[@]})

# dbg.space [SPACE]
# 1. global
# 2. file: no param
dbg.mark() {
    local id offset

    # don't use source.name since it would return devel.sh while using this
    # function in other scripts
    id=$(basename ${BASH_SOURCE[1]})
    id="${1:-$id}"

    offset=$(list.index_of __DEVEL_BASH_DBG_SPACE_LIST "$id")
    [[ -n "$offset" ]] && return 1

    list.insert __DEVEL_BASH_DBG_SPACE_LIST "$id"
    echo "$id"
}

dbg.mark ${__DBG_ALL} > $__N

dbg.file() {
    [[ -z "$1" ]] && return 1
    __DBG_FD="$1"
}

# dbg.on [SPACE]
# 1. turn on global space => no param
# 2. turn on specific space => others
dbg.on() {
    local offset idx

    [[ -n "$__DBG_FD" ]] && exec &> >(tee $__DBG_FD)

    if [[ -z "$1" ]]; then
        dbg.on "${__DBG_ALL}"
        return
    fi

    offset=$(list.index_of __DEVEL_BASH_DBG_SPACE_LIST "$1")
    if [[ -z "$offset" ]]; then
        dbg.mark "$1"
        offset=$(list.index_of __DEVEL_BASH_DBG_SPACE_LIST "$1")
    fi

    idx=$(list.index_of __DEVEL_BASH_CUR_SPACE_LIST "$offset")
    [[ -n "$idx" ]] && return

    eval "exec $(__dbg_fd $offset)>&1"
    list.insert __DEVEL_BASH_CUR_SPACE_LIST $offset
}

# XXX:
# should place dbg.off in the end of the file
# side effect:
# 1. the debug file could not be disabled
dbg.off() {
    local offset idx

    if [[ -n "$__DBG_FD" ]]; then
        unset __DBG_FD
    fi

    if [[ -z "$1" ]]; then
        dbg.off "${__DBG_ALL}"
        return
    fi

    offset=$(list.index_of __DEVEL_BASH_DBG_SPACE_LIST "$1")
    [[ -z "$offset" ]] && return 1

    idx=$(list.index_of __DEVEL_BASH_CUR_SPACE_LIST "$offset")
    [[ -z "$idx" ]] && return 1

    eval "exec $(__dbg_fd $offset)>&-"
    list.remove __DEVEL_BASH_CUR_SPACE_LIST $idx
}

# dbg.cmd CMD
dbg.cmd() {
    __DBG_IDX=2 msg.dbg "$*"
    # echo ${BASH_SOURCE[@]}
    # msg.dbg "$*"
    eval "$*"
}

dbg.cmd_stop() {
    __DBG_IDX=2 msg.dbg "$*"
    # msg.dbg "$*"
    eval "$*" || exit $?
}

dbg.dumpstack() {
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

# Check
is_uint() { case $1        in '' | *[!0-9]*              ) return 1;; esac ;}
is_int()  { case ${1#[-+]} in '' | *[!0-9]*              ) return 1;; esac ;}
is_unum() { case $1        in '' | . | *[!0-9.]* | *.*.* ) return 1;; esac ;}
is_num()  { case ${1#[-+]} in '' | . | *[!0-9.]* | *.*.* ) return 1;; esac ;}
is_hex()  { ((16#$1)) &> $__N || return 1; }

# pause [ret]
pause() {
    read -p "Press ENTER to continue."
    return $1
}

__DEVEL_BASH_AFTER="$(compgen -A function) $(compgen -v)"

# time __DEVEL_BASH_INCLUDED=$(comm -23 <(printf "%s\n" $' '"$__DEVEL_BASH_AFTER" | sort) <(printf "%s\n" $' '"$__DEVEL_BASH_BEFORE" | sort))
# time __DEVEL_BASH_INCLUDED=$(printf "%s\n" $__DEVEL_BASH_AFTER | grep -Fvx -f <(printf "%s\n" $__DEVEL_BASH_BEFORE))
__DEVEL_BASH_INCLUDED=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__DEVEL_BASH_BEFORE) <(printf "%s\n" $__DEVEL_BASH_AFTER))

unset __DEVEL_BASH_AFTER __DEVEL_BASH_BEFORE
