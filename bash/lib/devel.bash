#!/usr/bin/env bash

[[ -v __DEVEL_BASH_INCLUDED ]] && return
__DEVEL_BASH_INCLUDED='none'

__bash_env_record_begin

__N=/dev/null
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

# $0 VAR PATH
# Append to the last pos
path.append() {
  local var="$1"
  local dir="$2"

  eval "$var=\"\${$var:+\${$var}:}$dir\""
}

# $0 VAR PATH
# Prepend to the first pos
path.prepend() {
  local var="$1"
  local dir="$2"

  eval "$var=\"$dir\${$var:+:\${$var}}\""
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
    eval "path.abs \"\${BASH_SOURCE[1]}\""
}

source.dirname() {
    source.path | xargs dirname
} 2> $__N

source.name() {
    eval "basename \"\${BASH_SOURCE[1]}\""
} 2> $__N

msg.err() {
    local r=$?
    if [[ "$r" -eq 0 ]]; then
        r=255
    fi
    msg "ERROR: $*" >&2
    return $r
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

# list.idx_of LIST VALUE
list.idx_of() {
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
    [[ -z "$(list.idx_of \"$1\" \"$2\")" ]] &> $__N
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

__bash_env_record_end
