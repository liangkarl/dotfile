#!/bin/bash

source $SHELL_CORE_DIR/core.sh

PACK_REPOS_NAME=('npm' 'yarn' 'pip' 'pip3' 'brew')

install_npm_from_npmjs_org()
{
    has_cmd curl || return
    curl http://npmjs.org/install.sh | sh
}

install_npm_from_nodesource()
{
    has_cmd curl || return
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
	local NEED_CMD='curl wget file git'
    has_these_cmds "$NEED_CMD" || {
        show_err "$(info_req_cmd $NEED_CMD)"
        return
    }
	sudo apt-get install build-essential

	git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
	mkdir ~/.linuxbrew/bin
	ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
	eval $(~/.linuxbrew/bin/brew shellenv)
}

install()
{
    local name_list
    local npm_source pip_source pip3_source yarn_source
    local FROM

    npm_source='apt npmjs_org nodesource'
    pip_source='apt'
    pip3_source='apt'
    yarn_source='npm'
    brew_source='github'

    echo "Install ${PACK_REPOS_NAME[@]}..."

    for NAME in ${PACK_REPOS_NAME[@]}; do
        has_cmd $NAME && {
            show_hint "$(info_installed $NAME)"
            continue
        }

        echo "Install $NAME now"

        FROM=${NAME}_source
        for SRC in ${!FROM}; do
            install_${NAME}_from_${SRC}
            has_cmd $NAME && {
                echo "Install $NAME successfully"
                break
            }
            echo "Install $NAME from $SRC failed">&2
        done

        has_cmd $NAME || echo "No way to install $NAME">&2
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
