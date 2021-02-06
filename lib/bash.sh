#!/bin/bash

source $SHELL_CORE_DIR/utils.sh
source $SHELL_CORE_DIR/sign.sh

BASH='bash'
BASH_DIR="$SHELL_CONFIG_DIR/$BASH"

install() {
	config_package
}

uninstall() {
	echo "Remove $BASH..."
}

config_package() {
    local USR_BASH_DIR BASHRC
    local DIR FILE LIST CMD SRC

    echo "Config $BASH..."

    USR_BASH_DIR="$HOME_CONFIG_DIR/$BASH"
    BASHRC="$HOME/.bashrc"

    pushd $HOME

    DIR=bin
    [ ! -d $DIR ] && {
        echo "Create $DIR folder"
        mkdir $DIR
    }

    LIST="$(ls $SHELL_BIN_DIR/*)"
    for BIN in "$LIST"; do
        create_link $BIN $DIR/$BIN
    done

    [ -e $USR_BASH_DIR ] || mkdir $USR_BASH_DIR

    FILE='/etc/skel/.bashrc'
    [ -f $BASHRC ] || cp $FILE $BASHRC

    create_link $BASH_DIR/bash_aliases .bash_aliases
    create_link $BASH_DIR/bash_completion .bash_completion

    FILE="/etc/profile.d/bash_completion.sh"
    CMD=". $FILE"
    grep -wq "^$CMD" $BASHRC ||
        add_with_sig "$CMD" "$BASHRC" "$BASH"

    CMD=". $USR_BASH_DIR/init.bash"
    grep -wq "^$CMD" $BASHRC ||
        add_with_sig "$CMD" "$BASHRC" "$BASH"
    popd

    local ALIAS_DIR='alias'
    local COMPLETION_DIR='completion'
    pushd $USR_BASH_DIR
    create_link $BASH_DIR/init.bash .

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

    # $SHELL is from environment
    CMD=$(echo $SHELL | grep $BASH)
    [ "$CMD" != $BASH ] && sudo dpkg-reconfigure dash
}
