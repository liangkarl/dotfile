#!/usr/bin/env bash

[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=${HOME}/.config
[[ -z $XDG_DATA_HOME ]] && export XDG_DATA_HOME=${HOME}/.local/share
[[ -z $XDG_CACHE_HOME ]] && export XDG_CACHE_HOME=${HOME}/.cache

set -eE
[[ "${DEBUG}" == y ]] && set -xv
shopt -s extglob

# copy tool dirs to user config dir

me="$(basename $0)"
mydir="$(dirname $0)"
pfx="$(uname -s)-$(uname -m)"
pfx="${pfx//aarch64/arm64}"

local_bin="${HOME}/.local/bin"
toolkit="${XDG_CONFIG_HOME}/toolkit"
toolkit_script="$toolkit/script"

cp -rf $mydir/{bin,script} $toolkit
if [[ -n "$SHELL_DIR" ]]; then
    grep -q "SCRIPT_DIR" $SHELL_DIR/config \
            || echo "export SCRIPT_DIR=${toolkit_script}" >> $SHELL_DIR/config
else
    echo "\$SHELL_DIR does not exist"
fi

# copy bin/ script/ to toolkit
[[ ! -d "$local_bin" ]] && mkdir $local_bin

for file in $(ls $mydir/prebuild); do
    cp -f $mydir/prebuild/$file/$file-${pfx,,} $local_bin/$file || true
done

for file in $(ls $mydir/bin); do
    cp -f $mydir/bin/$file $local_bin/$file || true
done

# create special files in $HOME/bin
fake="$(readlink -e ${toolkit_script}/fake)"
while IFS= read -r file
do
    # don't force override as this is a 'fake' file
    ln -s $fake $local_bin/$(basename $file) || true
done < $mydir/fake.list

echo "-- Clean $toolkit --"
rm -rf $toolkit
