#!/bin/bash

set -eE
[[ "${DEBUG}" == y ]] && set -xv
shopt -s extglob

# copy tool dirs to user config dir

self="$(basename $0)"
tools_dir="$(dirname $0)"
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/shell"
black_list="$self|test|sample.sh"
bin_dir="${HOME}/bin"

echo "-- Copy tools to $config_dir --"
[[ ! -d "$config_dir" ]] && mkdir $config_dir
cp -r $tools_dir/!(${black_list}) $config_dir

# link executable files to $HOME/bin

echo "-- Link $config_dir to $bin_dir --"
[[ ! -d "$bin_dir" ]] && mkdir $bin_dir

# clean invailid links
list="$(find ${config_dir} -type f -exec 'readlink' '-e' '{}' ';')"
find $bin_dir -xtype l -delete

for file in ${list[@]}; do
    link_pname=${bin_dir}/$(basename $file)

    # clean non-link or invalid link
    if [[ ! -h ${link_pname} ]]; then
        rm -f ${link_pname}

    # clean the mislead link
    elif [[ "$(readlink ${link_pname})" != ${file} ]]; then
        rm -f ${link_pname}
    fi

    ln -sf $file $bin_dir
done
