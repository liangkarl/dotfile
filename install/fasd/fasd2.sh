#!/usr/bin/env bash

source $SHELL_CORE_DIR/core.sh
source $SHELL_CORE_DIR/installer.sh

FASD='fasd'
FASD_DIR="$SHELL_CONFIG_DIR/$FASD"

install() {
    already_has_cmd $FASD && return $?

    echo "Install $FASD..."
    add_ppa_repo "ppa:aacebedo/fasd"
    sudo apt update
    sudo apt install -y $FASD

    check_install_cmd $FASD || return $?

    config_package
}

uninstall() {
    echo "Remove $FASD..."
    sudo apt purge $FASD
}

config_package() {
    local CMD BASHRC
    CMD='eval "$(fasd --init auto)"'
    BASHRC=$HOME/.bashrc

    echo "Config $FASD..."
    add_with_sig "$CMD" "$BASHRC" "$FASD"
}
