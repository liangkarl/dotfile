#!/bin/bash

source $SHELL_CORE_DIR/core.sh

GIT='git'
GIT_DIR="$SHELL_CONFIG_DIR/$GIT"

git_install_tig() {
    echo "install tig"
    sudo apt install -y tig
}

git_config_tig() {
    echo "config tig"
    goto $HOME
    link $GIT_DIR/tigrc .tigrc
    back
}

git_install_git() {
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt-get update
    echo "install git"
    sudo apt install -y $GIT
}

git_config_git() {
    local GITCONFIG
    GITCONFIG="$GIT_DIR/gitconfig"

    echo "config git"
    goto $HOME
    link $GITCONFIG .gitconfig
    back
}

git_install() {
    local FORCE
    FORCE="$1"

    echo "Start installing $GIT"
    install_exector $GIT "${GIT}_install_" $FORCE
}

git_remove() {
    echo "Remove $GIT..."
    sudo apt purge $GIT
}

git_config() {
    local FORCE
    FORCE="$1"

    echo "Config $GIT..."
    install_exector $GIT "${GIT}_config_" $FORCE
}

git_list() {
    install_lister $GIT $@
}
