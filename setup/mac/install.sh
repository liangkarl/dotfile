#!/usr/bin/env bash

# install package manager

# install core utils
brew install findutils
brew install gnu-indent
brew install gnu-sed
brew install gnutls
brew install grep
brew install gnu-tar
brew install gawk

# gls, and etc
brew install coreutils

# update-alternative
brew install dpkg

brew install bash-completion@2

brew install neovim

url='https://github.com/junegunn/fzf.git'
pos="${XDG_CONFIG_HOME}/fzf"
git clone --depth=1 $url $pos
eval ${pos}/install

nvim +PlugInstall +qa

lib.load system

sys.auto_alter_cmd ls
sys.auto_alter_cmd vim
sys.alter_cmd vim $(which nvim)
