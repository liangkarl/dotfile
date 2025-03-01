#!/usr/bin/env bash

path.uniq() {
    echo "${*%/}" | tr -s /
}

path.abs() {
    realpath -m -s "$@"
}

path.rel() {
    realpath -m -s --relative-to=$(pwd) "$@"
}

# call the func to get the file path inside the sourced script
path.in_source() { echo "$(readlink -e "$(dirname ${BASH_SOURCE[0]})")"; }

# usage:
# path.load FILE [PATH]
path.load() {
    local path

    path="$2"
    [[ -z "$path" ]] && path=$(pwd)
    path="$(path.abs $path)"

	while [[ ! -e ${path}/$1 ]]; do
        [[ -z "${path}" ]] && echo "$1" && break 1
        path="${path%/*}"
	done

    echo ${path}/$1
}

source.load() {
    source $(path.load $*)
}

msg.exit() {
    local r
    r=$1; shift
    echo "$*"
    exit $r
}

# Load the help information on the top of the file
# These information is written in normal bash comments format
# and stop with single empty line.
msg.help() {
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
    local $1
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

#msg.err()
#msg.good()
