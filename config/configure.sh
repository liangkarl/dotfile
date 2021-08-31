#!/bin/bash

# TODO: need more flexible setup

# Copy config to right place
target="${XDG_CONFIG_HOME:-${HOME}/.config}"
self="$(basename $0)"
config_dir="$(dirname $0)"

if [[ ! -e "$target" ]]; then
    mkdir $target
fi

echo "Copy config to $target"
cp -r ${config_dir} ${target}/
rm -f ${target}/${self}

echo -n "Add path of shell dir: "
echo "export SHELL_DIR=$(readlink -e ${config_dir}/..)" |
        tee ${target}/bash/config

bashrc=~/.bashrc
import="source ${target}/bash/init.bash"
has_init="$(cat ${bashrc} | grep "${import}")"
if [[ -z "$has_init" ]]; then
    echo $import >> ${bashrc}
fi
