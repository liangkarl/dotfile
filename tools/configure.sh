#!/usr/bin/env bash

set -eE
[[ "${DEBUG}" == y ]] && set -xv
shopt -s extglob

# copy tool dirs to user config dir

self="$(basename $0)"
tools_dir="$(dirname $0)"
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/shell"
black_list="$self|test|sample.sh"
bin_dir="${HOME}/bin"
me="$(basename $0)"
mydir="$(dirname $0)"
home_bin="${HOME}/bin"
toolkit="${XDG_CONFIG_HOME:-${HOME}/.config}/toolkit"
toolkit_bin="$toolkit/bin"
toolkit_script="$toolkit/script"

echo "-- Copy tools to $config_dir --"
[[ ! -d "$config_dir" ]] && mkdir $config_dir
cp -r $tools_dir/!(${black_list}) $config_dir

# link executable files to $HOME/bin

echo "-- Link $config_dir to $bin_dir --"
[[ ! -d "$bin_dir" ]] && mkdir $bin_dir

list="$(find ${config_dir} -type f -exec 'readlink' '-e' '{}' ';')"

# clean invailid links
find $bin_dir -type l ! -exec test -e {} \; -delete

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

# create special files in $HOME/bin
fake="$(readlink -e ${toolkit_script}/fake)"
while IFS= read -r file
do
    # don't force override as this is a 'fake' file
    ln -s $fake $home_bin/$(basename $file) || true
done < $mydir/fake.list
