#!/bin/bash

set -eE

# Ubuntu distro number presumption
os_ver="$(lsb_release -r | awk '{print $2}')"

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

# yarn
package='yarn'
echo "-- Install $package --"
sudo npm install --global $package
echo "-- $package version: $($package --version) --"

# pip
if (( $os_ver <= 18.04 )); then
    package='python-pip'
    echo "-- Install $package --"
    sudo apt install $package
    echo "-- $package version: $(pip --version) --"
fi

# pip3
package='python3-pip'
echo "-- Install $package --"
sudo apt install $package
echo "-- $package version: $(pip3 --version) --"

# cargo (Rust)
package='cargo'
echo "-- Install $package --"
curl https://sh.rustup.rs -sSf | sh
echo "-- $package version: $($package --version) --"

# brew
# https://docs.brew.sh/Homebrew-on-Linux
#
# FIXME: need more test on brew install
#
# package='brew'
# url='https://github.com/Homebrew/brew'
# pos="${XDG_CONFIG_HOME:-~/.linuxbrew}/Homebrew"
# bin_dir="$HOME/bin"
# echo "-- Install $package --"
# git clone --depth=1 $url $pos
# if [[ ! -d $bin_dir ]]; then
#     mkdir $bin_dir
# fi
# ln -sf ${pos}/bin/brew $bin_dir
# eval $(${bin_dir}/brew shellenv)
# echo "-- $package version: $($package --version) --"
