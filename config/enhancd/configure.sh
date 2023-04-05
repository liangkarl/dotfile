#!/usr/bin/env bash

dir="$(realpath -m -s $(dirname $0))"
dir=${1:-$dir}
tmp="$(mktemp -d)"
cmd="source $dir/bootstrap.sh"

trap "rm -rf $tmp" EXIT

git clone -n --depth=1 https://github.com/b4b4r07/enhancd.git $tmp

cp -rf ${tmp}/.git $dir
git -C $dir reset --hard HEAD

echo "source $dir/init.sh" >> $dir/bootstrap.sh
grep -q -w "$cmd" ~/.bashrc ||
        echo -e "\n$cmd" >> ~/.bashrc
