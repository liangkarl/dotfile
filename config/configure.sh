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
