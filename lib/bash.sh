#!/bin/bash

source $SHELL_CORE_DIR/utils.sh
source $SHELL_CORE_DIR/sign.sh

BASH_NAME='bash'
BASH_CONFIG="$SHELL_CONFIG_DIR/$BASH_NAME"

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

    local -r USR_CONFIG="$HOME/.config/$BASH_NAME"
    local -r BASHRC="$HOME/.bashrc"
    local -r BASH_COMPLETION="/etc/profile.d/bash_completion.sh"
    local -r INITRC="init.bash"
    local LOAD_CMD=''
    local SRC=''

    pushd $HOME
    [ -e $USR_CONFIG ] || mkdir $USR_CONFIG

    [ -f $BASHRC ] || cp /etc/skel/.bashrc $BASHRC
    SRC=$BASH_CONFIG
    create_link $SRC/bash_aliases .bash_aliases
    create_link $SRC/bash_completion .bash_completion

    LOAD_CMD=". $BASH_COMPLETION"
    grep -wq "^$LOAD_CMD" $BASHRC ||\
        add_with_sig "$LOAD_CMD" "$BASHRC" "$BASH_NAME"

    LOAD_CMD=". $USR_CONFIG/$INITRC"
    grep -wq "^$LOAD_CMD" $BASHRC ||\
        add_with_sig "$LOAD_CMD" "$BASHRC" "$BASH_NAME"
    popd

    local -r ALIAS_DIR='alias'
    local -r COMPLETION_DIR='completion'
    pushd $USR_CONFIG
    SRC=$BASH_CONFIG
    create_link $SRC/init.bash .

    [ -e $ALIAS_DIR ] || mkdir $ALIAS_DIR
    pushd $ALIAS_DIR
    SRC="$BASH_CONFIG/$ALIAS_DIR"
    create_link $SRC/alias_common .
    create_link $SRC/alias_working .
    popd

    [ -e $COMPLETION_DIR ] || mkdir $COMPLETION_DIR
    pushd $COMPLETION_DIR
    SRC="$BASH_CONFIG/$COMPLETION_DIR"
    #create_link $SRC/ .
    popd
    popd # $USR_CONFIG

    sudo dpkg-reconfigure dash
}
