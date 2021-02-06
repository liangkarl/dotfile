#!/bin/bash

source $SHELL_CORE_DIR/core.sh

FASD_NAME='fasd'
FASD_DIR="$SHELL_CONFIG_DIR/$FASD_NAME"

install()
{
    add_ppa_repo "ppa:aacebedo/fasd"
    install_if_no $FASD_NAME
    # config_package
}

uninstall()
{
        echo "Remove $FASD_NAME..."
        echo "Not finished yet..."

        # Remove package itself without system configs
        # sudo apt remove fasd

        # Remove package itself & system config
        # sudo apt purge fasd

        # Remove related dependency
        # sudo apt autoremove

        # still remain user configs
}

config_package()
{
        echo "Config $FASD_NAME..."

        local CMD='eval "$(fasd --init auto)"'
        local BASHRC=$HOME/.bashrc

        add_with_sig "$CMD" "$BASHRC" "$FASD_NAME"
}
