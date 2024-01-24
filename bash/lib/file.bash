#!/usr/bin/env bash

trim_slash_end() { echo ${@%/}; }

trim_slash() { echo "$@" | tr -s /; }

trim_path() { trim_slash_end "$(trim_slash "$@")"; }

abs_path() { echo $(realpath -m -s "$@"); }

rel_path() { echo $(realpath -m -s --relative-to=$(pwd) "$@"); }

is_rel_path() { [[ "$@" =~ ^([^/~]|$) ]] || return 1; }

# usage:
#   $0 file.name /path/to/dir
find_path() {
	local dir file ret

	file="$1"
	[[ -z "$file" ]] && return 1

	dir="$(abs_path $2)"
	[[ -z "$dir" ]] && return 2

	ret="${dir}/${file}"
	while [[ ! -e ${ret} ]]; do
		if [[ "$dir" == "/" ]]; then
			ret=''
			return 1
		fi

		dir=$(dirname $dir)
		ret="${dir}/${file}"
	done

	echo $ret
}

# usage:
#   $0 /path/to/file.name => search file.name from assigned wd
#	$0 file.name => search file.name from cwd
find_file_path() { find_path "$(basename $1)" "$(dirname $1)"; }

source_file() { source $(find_file_path "$1"); }

# call the func to get the file path inside the sourced script
source_file_path() { echo "$(readlink -e "$(dirname ${BASH_SOURCE[0]})")"; }
