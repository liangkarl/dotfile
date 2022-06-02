#!/usr/bin/env bash

install_brew_from_github()
{
	local NEED_CMD
    local HOMEBREW
    NEED_CMD='curl wget file git'
    need_cmd $NEED_CMD || return $?

	sudo apt install build-essential

    HOMEBREW=$HOME/.linuxbrew
    [ ! -e $HOMEBREW ] &&
        mkdir $HOMEBREW

    goto $HOMEBREW
    [ ! -e Homebrew ] &&
        git clone https://github.com/Homebrew/brew Homebrew
    back

    [ ! -e $HOME_BIN_DIR ] &&
        mkdir $HOME_BIN_DIR
    goto $HOME_BIN_DIR
    link $HOMEBREW/Homebrew/bin/brew .
    back
	eval $(brew shellenv)
}

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
