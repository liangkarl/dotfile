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
cat > ${config_dir}/config <<-EOF
lib.add() {
    if [[ -z "\$SHELL_DIR" ]]; then
        echo "\\\$SHELL_DIR wasn't defined"
        return 1
    elif [[ ! -e "\$SHELL_DIR" ]]; then
        echo "'\$SHELL_DIR' wasn't existed"
        return 2
    elif [[ -z "\$1" ]]; then
        echo "Empty input"
        return 3
    elif [[ ! -e "\$SHELL_DIR/lib/\$1" ]]; then
        echo "'\$1' doesn't exist"
        return 4
    fi

    source "\$SHELL_DIR/lib/\$1"
}

export -f lib.add
export SHELL_DIR="$(dirname $0)"

# Remove duplicated path
PATH="\$(echo -n \$PATH | sed -e 's/:/\n/g' | awk '!x[\$0]++' | tr '\n' ':')"
EOF

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
