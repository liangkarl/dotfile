#!/bin/bash

source $SHELL_CORE_DIR/core.sh

GIT='git'
GIT_DIR="$SHELL_CONFIG_DIR/$GIT"

install() {
    has_cmd $GIT && {
        show_hint "$(info_installed $GIT)"
        return
    }

    echo "Start installing $GIT"
    sudo apt install -y $GIT
    config_package
}

uninstall() {
    echo "Remove $GIT..."
    sudo apt purge $GIT
}

config_package() {
    local GITCONFIG
    GITCONFIG="$GIT_DIR/gitconfig"

    echo "Config $GIT..."

    pushd $HOME
    link $GITCONFIG .gitconfig
    popd
}
