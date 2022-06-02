#!/usr/bin/env bash

set -eE

LOCATION[pip3]=("here")

# pip3
package='python3-pip'
echo "-- Install $package --"
sudo apt install $package
echo "-- $package version: $(pip3 --version) --"

sudo apt install python3-pip
echo "-- $package version: $(pip3 --version) --"
