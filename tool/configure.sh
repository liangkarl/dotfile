#!/usr/bin/env bash

[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=${HOME}/.config
[[ -z $XDG_DATA_HOME ]] && export XDG_DATA_HOME=${HOME}/.local/share
[[ -z $XDG_CACHE_HOME ]] && export XDG_CACHE_HOME=${HOME}/.cache

# set -v
set -eE
[[ "${DEBUG}" == y ]] && set -xv
shopt -s extglob

# copy tool dirs to user config dir

me="$(basename $0)"
mydir="$(dirname $0)"
pfx="$(uname -s)-$(uname -m)"
pfx="${pfx//aarch64/arm64}"

l_bin="${HOME}/.local/bin"

# copy bin/ script/ to toolkit
[[ ! -d "$l_bin" ]] && mkdir $l_bin

for file in $(ls $mydir/prebuild); do
    cp -f $mydir/prebuild/$file/$file-${pfx,,} $l_bin/$file || true
done

for file in $(ls $mydir/bin); do
    cp -f $mydir/bin/$file $l_bin/$file || true
done

# TODO: copy and link the scripts to proper place

# create special files in $HOME/bin
# fake="${mydir}/script/fake"
# while IFS= read -r file
# do
#     # don't force override as this is a 'fake' file
#     ln -sf $fake $l_bin/$(basename $file) || true
# done < $mydir/fake.list
