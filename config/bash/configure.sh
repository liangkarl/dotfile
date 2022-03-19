#!/usr/bin/env bash -e

# check XDG_CONFIG_HOME dir
config_dir=${XDG_CONFIG_HOME}

echo "-- setup bash config --"

# add customized variable
echo "-- add path of shell dir --"
echo "export SHELL_DIR=$(dirname $0)" |
        tee ${config_dir}/bash/config

# check bash config
case "$OS" in
    Linux)
        bashrc="$HOME/.bashrc"
        ;;
    Darwin)
        bashrc="$HOME/.bash_profile"
        ;;
    *)
        echo "warning: no suitable .bashrc for '$OS'"
        bashrc="$HOME/.bashrc"
        echo "use default bashrc, '$bashrc'"
        ;;
esac

# import setup in .bashrc
echo "-- import setup in '$bashrc' --"
ibash="$XDG_CONFIG_HOME/bash/init.bash"
if [[ ! -e "$ibash" ]]; then
    echo "'$ibash' isn't existed"
    exit 1
fi

import="source ${config_dir}/bash/init.bash"
if ! grep -q "$import" ${bashrc}; then
    echo "" >> $bashrc
    echo "# load dotfile bash config" >> $bashrc
    echo "$import" >> $bashrc
fi
