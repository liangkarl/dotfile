#!/usr/bin/env bash

install_npm_from_npmjs_org()
{
    already_has_cmd curl || return $?
    curl http://npmjs.org/install.sh | sh
}

install_npm_from_nodesource()
{
    already_has_cmd curl || return $?
	curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
	sudo apt install nodejs
}

install_npm_from_apt()
{
    sudo apt install nodejs
    sudo apt install nodejs-legacy
    sudo apt install npm
}

# nodejs LTS with npm
package='nodejs'
echo "-- Install $package --"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y $package

# optional: To compile and install native addons from npm,
#           you may also need to install build tools
sudo apt install -y build-essential

echo "-- $package version: $(nodejs --version) --"
echo "-- npm version: $(npm --version) --"

