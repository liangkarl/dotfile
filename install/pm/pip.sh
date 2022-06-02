#!/usr/bin/env bash

set -eE

LOCATION[pip]=("here")

# Ubuntu
sudo apt install python-pip

# pip
if (( $os_ver <= 18.04 )); then
    package='python-pip'
    echo "-- Install $package --"
    sudo apt install $package
    echo "-- $package version: $(pip --version) --"
fi


echo "-- $package version: $(pip --version) --"
