#!/usr/bin/env bash

#brew install neovim

url='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
curl -fLo ${XDG_DATA_HOME}/nvim/site/autoload/plug.vim --create-dirs $url

url='https://github.com/junegunn/fzf.git'
pos="${XDG_CONFIG_HOME}/fzf"
git clone --depth=1 $url $pos
eval ${pos}/install

nvim +PlugInstall +qa
