#!/bin/bash

source $SHELL_CORE_DIR/core.sh

GIT='git'
GIT_DIR="$SHELL_CONFIG_DIR/$GIT"
TIG_DIR="$SHELL_CONFIG_DIR/tig"

git_install_tig() {
    echo "install tig"
    sudo apt install -y tig
}

git_config_tig() {
    echo "config tig"
    goto $HOME
    link $TIG_DIR/tigrc .tigrc
    back
}

git_install_git() {
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
    local FORCE ALL
    FORCE=$(echo $1 | grep force)
    ALL=$(declare -F | awk '{print $3}' | grep -E "^${GIT}_install_")

    [ -z $FORCE ] && {
        has_cmd $GIT || break

		show_hint "$(info_installed $GIT)"
		return
	}

    echo "Start installing $GIT"
    for EXEC in $ALL; do
        $EXEC
    done
}

git_remove() {
    echo "Remove $GIT..."
    sudo apt purge $GIT
}

git_config() {
    local FORCE ALL
    FORCE=$(echo $1 | grep force)
    ALL=$(declare -F | awk '{print $3}' | grep -E "^${GIT}_config_")

    [ -z $FORCE ] && {
        has_cmd $GIT || break

		show_hint "$(info_installed $GIT)"
		return
	}

    echo "Config $GIT..."
    for EXEC in $ALL; do
        $EXEC
    done
}

git_list() {
    while :; do
        [ -z "$1" ] && break
        case $1 in
            c|-c|--config)
                echo "List config available function(s) as below"
                declare -F | awk '{print $4}' | grep -E "^${GIT}_config"
                ;;
            i|-i|--install)
                echo "List install available function(s) as below"
                declare -F | awk '{print $3}' | grep -E "^${GIT}_install"
                ;;
            r|-r|--remove)
                echo "List remove available function(s) as below"
                declare -F | awk '{print $3}' | grep -E "^${GIT}_remove"
                ;;
            *)
                show_err "not support option '$1'"
        esac
        shift
        echo ""
    done
}
