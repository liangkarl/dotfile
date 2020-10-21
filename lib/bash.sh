#!/bin/bash

source $CORE_DIR/utils.sh

BASH_NAME='bash'
BASH_CONFIG="$CONFIG_DIR/$BASH_NAME"

install()
{
        config_package
}

uninstall()
{
        echo "Remove $BASH_NAME..."
}

config_package()
{
        echo "Config $BASH_NAME..."

        ## Create config link
        local -r DST_CONFIG="$HOME/.bash_aliases"
        local -r SRC_CONFIG="$BASH_CONFIG/bash_aliases"
        create_link $SRC_CONFIG $DST_CONFIG
}
