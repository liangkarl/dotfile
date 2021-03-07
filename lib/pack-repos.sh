#!/bin/bash

source $SHELL_CORE_DIR/core.sh

PACK_REPOS_NAME=('npm' 'yarn' 'pip' 'pip3' 'brew')

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

install_pip_from_apt()
{
    sudo apt install python-pip
}

install_pip3_from_apt()
{
    sudo apt install python3-pip
}

install_yarn_from_npm()
{
    sudo npm -g install yarn
}

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

install()
{
    local name_list
    local npm_source pip_source pip3_source yarn_source
    local FROM

    npm_source='npmjs_org nodesource apt'
    pip_source='apt'
    pip3_source='apt'
    yarn_source='npm'
    brew_source='github'

    echo "Install ${PACK_REPOS_NAME[@]}..."

    for NAME in ${PACK_REPOS_NAME[@]}; do
        already_has_cmd $NAME && continue

        echo "Install $NAME now"

        FROM=${NAME}_source
        for SRC in ${!FROM}; do
            echo "Install $NAME from $SRC"
            install_${NAME}_from_${SRC}
            check_install_cmd $NAME && break
        done
    done
}


uninstall()
{
    echo "Remove $PACK_REPOS_NAME..."
    echo "Not finished yet..."
}

config_package()
{
    echo "Config $PACK_REPOS_NAME..."
    echo "Not finished yet..."
}
