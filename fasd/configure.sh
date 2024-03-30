#!/usr/bin/env bash

set -x

dir="$(realpath -m -s $(dirname $0))"
dir=${1:-$dir}
tmp="$(mktemp -d)"
line='eval "$(fasd --init auto)"'

trap "rm -rf $tmp" EXIT

git clone -n --depth=1 https://github.com/clvv/fasd.git $tmp

cp -rf ${tmp}/.git $dir
git -C $dir reset --hard HEAD

ln -sf $dir/fasd ~/bin/fasd
ln -sf $dir/fasdrc ~/.fasdrc
grep -q -w "$line" ~/.bashrc ||
        printf -- "\n$line\n" >> ~/.bashrc
