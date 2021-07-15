#!/bin/bash

# TODO: need more flexible setup

# Copy config to right place
target="${XDG_CONFIG_HOME:-~/.config}"
config="$(dirname $0)"

# FIXME: don't copy this script
cp -vr ${config}/* $target/
