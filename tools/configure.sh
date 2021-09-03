#!/bin/bash

set -eE
shopt -s extglob

# copy tool dirs to user config dir
self="$(basename $0)"
tools_dir="$(dirname $0)"
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/shell"
black_list="$self|test"
if [[ ! -d "$config_dir" ]]; then
    mkdir $config_dir
fi
echo "-- Copy tools to $config_dir --"
cp -r $tools_dir/!(${black_list}) $config_dir

# link executable files to $HOME/bin
bin_dir="${HOME}/bin"
if [[ ! -d "$bin_dir" ]]; then
    mkdir $bin_dir
fi
echo "-- Link $config_dir to $bin_dir --"
list="$(find ${config_dir} -type f -exec 'readlink' '-e' '{}' ';')"
for file in ${list[@]}; do
    ln -sf $file $bin_dir
done
