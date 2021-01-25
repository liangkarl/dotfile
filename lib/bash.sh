#!/bin/bash

source $SHELL_CORE_DIR/utils.sh
source $SHELL_CORE_DIR/sign.sh

BASH='bash'
BASH_DIR="$SHELL_CONFIG_DIR/$BASH"

install()
{
	config_package
}

uninstall()
{
	echo "Remove $BASH..."
}

config_package()
{
    echo "Config $BASH..."

    local USR_BASH_DIR="$USR_CONFIG_DIR/$BASH"
    local BASHRC="$HOME/.bashrc"
    local BASH_COMPLETION="/etc/profile.d/bash_completion.sh"
    local INITRC="init.bash"
    local CMD=''
    local SRC=''

    pushd $HOME
    [ -e $USR_BASH_DIR ] || mkdir $USR_BASH_DIR

    [ -f $BASHRC ] || cp /etc/skel/.bashrc $BASHRC
    SRC=$BASH_DIR
    create_link $SRC/bash_aliases .bash_aliases
    create_link $SRC/bash_completion .bash_completion

    CMD=". $BASH_COMPLETION"
    grep -wq "^$CMD" $BASHRC ||\
        add_with_sig "$CMD" "$BASHRC" "$BASH"

    CMD=". $USR_BASH_DIR/$INITRC"
    grep -wq "^$CMD" $BASHRC ||\
        add_with_sig "$CMD" "$BASHRC" "$BASH"
    popd

    local ALIAS_DIR='alias'
    local COMPLETION_DIR='completion'
    pushd $USR_BASH_DIR
    SRC=$BASH_DIR
    create_link $SRC/init.bash .

    [ -e $ALIAS_DIR ] || mkdir $ALIAS_DIR
    pushd $ALIAS_DIR
    SRC="$BASH_DIR/$ALIAS_DIR"
    create_link $SRC/alias_common .
    create_link $SRC/alias_working .
    popd

    [ -e $COMPLETION_DIR ] || mkdir $COMPLETION_DIR
    pushd $COMPLETION_DIR
    SRC="$BASH_DIR/$COMPLETION_DIR"
    #create_link $SRC/ .
    popd
    popd # $USR_BASH_DIR

    CMD=$(ls -l /bin/sh | awk -F'->' '{print $2}' | xargs)
    [ "$CMD" != $BASH ] && sudo dpkg-reconfigure dash
}
