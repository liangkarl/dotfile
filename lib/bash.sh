#!/bin/bash

source $SHELL_CORE_DIR/core.sh

BASH='bash'
BASH_DIR="$SHELL_CONFIG_DIR/$BASH"

bash_config_bash() {
    local USR_BASH_DIR BASHRC
    local DIR FILE LIST CMD SRC

    echo "Config $BASH..."

    USR_BASH_DIR="$HOME_CONFIG_DIR/$BASH"
    BASHRC="$HOME/.bashrc"

    goto $HOME

    DIR=bin
    [ ! -d $DIR ] &&
        mkdir $DIR

    goto $DIR
    LIST="$(ls $SHELL_BIN_DIR/*)"
    for BIN in $LIST; do
        link $BIN .
    done
    back

    [ -e $USR_BASH_DIR ] || mkdir -p $USR_BASH_DIR

    FILE='/etc/skel/.bashrc'
    [ -f $BASHRC ] || cp $FILE $BASHRC

    link $BASH_DIR/bash_aliases .bash_aliases
    link $BASH_DIR/bash_completion .bash_completion

    FILE="/etc/profile.d/bash_completion.sh"
    CMD=". $FILE"
    grep -wq "^$CMD" $BASHRC ||
        add_with_sig "$CMD" "$BASHRC" "$BASH"

    CMD=". $USR_BASH_DIR/init.bash"
    grep -wq "^$CMD" $BASHRC ||
        add_with_sig "$CMD" "$BASHRC" "$BASH"
    back

    local ALIAS_DIR COMPLETION_DIR
    ALIAS_DIR='alias'
    COMPLETION_DIR='completion'
    goto $USR_BASH_DIR
    link $BASH_DIR/init.bash .

    [ -e $ALIAS_DIR ] || mkdir $ALIAS_DIR
    goto $ALIAS_DIR
    SRC="$BASH_DIR/$ALIAS_DIR"
    link $SRC/alias_common .
    link $SRC/alias_working .
    back

    [ -e $COMPLETION_DIR ] || mkdir $COMPLETION_DIR
    goto $COMPLETION_DIR
    SRC="$BASH_DIR/$COMPLETION_DIR"
    #link $SRC/ .
    back
    back # $USR_BASH_DIR

    # $SHELL is from environment
    if [[ "$SHELL" == 'dash' ]]; then
        sudo dpkg-reconfigure dash
    fi
}

bash_install() {
    local ARGS
    ARGS="$1"

    echo "Install $BASH..."
    __take_action $BASH install $ARGS
    return $?
}

bash_remove() {
    local ARGS
    ARGS="$1"

	echo "Remove $BASH..."
    __take_action $BASH remove $ARGS
    return $?

	# Remove package itself without system configs
	# sudo apt remove $BASH

	# Remove package itself & system config
	# sudo apt purge $BASH

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

bash_config() {
    local ARGS
    ARGS="$1"

    echo "Configure $BASH..."
    __take_action $BASH config $ARGS
    return $?
}

bash_list() {
    __show_list $BASH $@
    return $?
}
