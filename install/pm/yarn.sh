#!/usr/bin/env bash

install_yarn_from_npm()
{
    sudo npm -g install yarn
}

# yarn
package='yarn'
echo "-- Install $package --"
sudo npm install --global $package
echo "-- $package version: $($package --version) --"
