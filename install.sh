#!/bin/bash

## Load environment variables
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $ROOT/core/env.sh

# prepare basic functions
init_env $ROOT

## Link bin/ to ~/bin/
[[ ! -d $HOME/bin ]] && {
	echo "Create 'bin' folder"
	mkdir $HOME/bin
}
echo "Link files"
# ln with soft link, verbose, interactive, backup
ln -svib $ROOT/bin/* $HOME/bin/


## Install packages
# Load package libraries
source $CORE_DIR/installer.sh

# Install package
install_packages
