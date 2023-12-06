#!/usr/bin/env bash

# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=${HOME}/.config
[[ -z $XDG_DATA_HOME ]] && export XDG_DATA_HOME=${HOME}/.local/share
[[ -z $XDG_CACHE_HOME ]] && export XDG_CACHE_HOME=${HOME}/.cache

# check XDG_CONFIG_HOME dir
config_dir=${XDG_CONFIG_HOME}/bash

echo "-- setup bash config --"

# add customized variable
echo "-- add path of shell dir --"
echo "export SHELL_DIR=$(dirname $0)" |
        tee ${config_dir}/config
rc=( ['Linux']="$HOME/.bashrc"
	 ['Darwin']="$HOME/.bash_profile" )

# check bash config
bashrc="${rc[$OS]}"
if [[ -z ${bashrc} ]]; then
	echo "warning: no suitable .bashrc for '$OS'"
	bashrc="$HOME/.bashrc"
	echo "use default bashrc, '$bashrc'"
fi

# import setup in .bashrc
echo "-- import setup in '$bashrc' --"
ibash="$config_dir/init.bash"
if [[ ! -e "$ibash" ]]; then
    echo "'$ibash' isn't existed"
    exit 1
fi

import="source ${ibash}"
if ! grep -q "$import" ${bashrc}; then
	echo "source customized bash config in ${bashrc}"
	cat >> $bashrc <<-EOF
	# Keep this command in the last line
	# Load dotfile bash config
	if [[ -n \$SHELL_DIR ]]; then
		$import
	fi
	EOF
fi
