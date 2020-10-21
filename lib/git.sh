#!/bin/bash

source $CORE_DIR/utils.sh

GIT_NAME='git'
GIT_CONFIG="$CONFIG_DIR/$GIT_NAME"

install()
{
        if test_cmd $GIT_NAME; then
                echo "$GIT_NAME is already installed"
        else
                echo "Start installing $GIT_NAME"
                sudo apt install -y $GIT_NAME
                config_package
        fi
}

uninstall()
{
        echo "Remove $GIT_NAME..."
        sudo apt purge $GIT_NAME
}

config_package()
{
        echo "Config $GIT_NAME..."
        
        ## Create config link
        local -r DST_CONFIG="$HOME/.gitconfig"
        local -r SRC_CONFIG="$GIT_CONFIG/gitconfig"
        create_link $SRC_CONFIG $DST_CONFIG
}
