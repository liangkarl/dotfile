#!/bin/bash

source $SHELL_CORE_DIR/core.sh

FASD='fasd'
FASD_DIR="$SHELL_CONFIG_DIR/$FASD"

install() {
	has_cmd $FASD && {
		show_hint "$(info_installed $FASD)"
		return $BAD
	}

    echo "Install $FASD..."
    add_ppa_repo "ppa:aacebedo/fasd"
    sudo apt update
    sudo apt install -y $FASD

    has_cmd $FASD || {
        show_err $(info_install_failed $FASD)
        return $BAD
    }

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
