#!/usr/bin/env bash

has_cmd() { type -t "$1" &> /dev/null || return $?; }

has_cmds() {
    local cmd num

    for cmd in $@; do
        has_cmd $cmd || ((num++))
    done

    return $num
} &> /dev/null

in_wsl() { [[ -z "$WSL_DISTRO_NAME" ]] || return $?; }

os_ver() {
	local os

	# 'macOS'
	if has_cmd sw_vers; then
		os="$(sw_vers -productName)"

	# 'Ubuntu'
	elif has_cmd lsb_release; then
		os="$(lsb_release -i -s)"
	fi

	# unsupported os
	# return a null string and error code
	echo $os
} 2> /dev/null

# chk_ver [min-ver] [cur-ver]
# return 0 if current ver >= min ver.
chk_ver() {
	[  "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

OS_MACOS='macOS'
OS_UBUNTU='Ubuntu'
