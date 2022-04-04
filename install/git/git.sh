#!/usr/bin/env bash

source $SHELL_CORE_DIR/core.sh

GIT='git'
GIT_DIR="$SHELL_CONFIG_DIR/$GIT"

git_install_tig() {
    echo "install tig"
    apt_ins tig
}

git_config_tig() {
    echo "config tig"
    goto $HOME
    link $GIT_DIR/tigrc .tigrc
    back
}

git_install_git() {
    add_ppa_repo ppa:git-core/ppa
    apt_ins $GIT
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
    __take_action $GIT install $FORCE
    return $?
}

git_remove_git() {
    echo "Remove $GIT..."
    sudo apt purge $GIT
}

git_config() {
    local FORCE
    FORCE="$1"

    echo "Config $GIT..."
    __take_action $GIT config $FORCE
    return $?
}

git_list() {
    __show_list $GIT $@
    return $?
}
