#!/usr/bin/env bash

set -eE
[[ "${DEBUG}" == y ]] && set -xv
shopt -s extglob

# copy tool dirs to user config dir

me="$(basename $0)"
mydir="$(dirname $0)"
pfx="$(uname -s)-$(uname -m)"

home_bin="${HOME}/bin"
toolkit="${XDG_CONFIG_HOME:-${HOME}/.config}/toolkit"
toolkit_bin="$toolkit/bin"
toolkit_script="$toolkit/script"

echo "-- Clean $toolkit --"

rm -rf $toolkit

echo "-- Copy tools to $toolkit --"

mkdir $toolkit
cp -rf $mydir/{bin,script} $toolkit
grep -q "SCRIPT_DIR" $SHELL_DIR/config \
        || echo "export SCRIPT_DIR=${toolkit_script}" >> $SHELL_DIR/config

for file in $(ls $mydir/prebuild); do
    cp -f $mydir/prebuild/$file/$file-${pfx,,} $toolkit_bin/$file
done

# create links between $HOME/bin and $toolkit
echo "-- Link $toolkit to $home_bin --"

# copy bin/ script/ to toolkit
[[ ! -d "$home_bin" ]] && mkdir $home_bin

# get the full file path of the files in toolkit
list="$(find ${toolkit_bin} -type f -exec 'readlink' '-e' '{}' ';')"

# clean invailid links in home_bin
find $home_bin -type l ! -exec test -e {} \; -delete

for file in ${list[@]}; do
    link_pname=${home_bin}/$(basename $file)

    # clean non-link or invalid link
    if [[ ! -h ${link_pname} ]]; then
        rm -f ${link_pname}

    # clean the mislead link
    elif [[ "$(readlink ${link_pname})" != ${file} ]]; then
        rm -f ${link_pname}
    fi

    ln -sf $file $home_bin
done

# create special files in $HOME/bin
fake="$(readlink -e ${toolkit_script}/fake)"
while IFS= read -r file
do
    # don't force override as this is a 'fake' file
    ln -s $fake $home_bin/$(basename $file) || true
done < $mydir/fake.list
