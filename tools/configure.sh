#!/bin/bash

target="$HOME"
self="$(basename $0)"
tools_dir="$(dirname $0)"

if [[ ! -e "$target" ]]; then
    mkdir $target
fi

echo "Copy bin/ to $target"
cp -r ${tools_dir}/bin ${target}/
