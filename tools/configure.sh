#!/bin/bash

target="${XDG_CONFIG_HOME:-${HOME}/.config/shell}"
self="$(basename $0)"
tools_dir="$(dirname $0)"

if [[ ! -d "$target" ]]; then
    mkdir $target
fi
cp -r $tools_dir $target

bin_dir="${HOME}/bin"
if [[ ! -d "$bin_dir" ]]; then
    mkdir $bin_dir
fi
echo "link $target to ~/bin"

list="$(find ${tools_dir} -type f -exec 'readlink' '-e' '{}' ';')"
for file in ${list[@]}; do
    ln -s $file $bin_dir
done

# clean self
rm -f ${target}/$(basename ${tools_dir})/${self}
rm -f ${HOME}/bin/${self}
