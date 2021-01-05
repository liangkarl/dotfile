#!/bin/bash

source $CORE_DIR/utils.sh
source $CORE_DIR/sign.sh

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

    local -r ALIAS_FILES="
        bash_aliases
        alias_common
        alias_working
        init.bash
    "
    for FILE in $ALIAS_FILES; do
        local DST="${HOME}/.${FILE}"
        local SRC="${BASH_CONFIG}/${FILE}"
        ## Create config link
        create_link $SRC $DST
    done

	## Modify $PS1
	# Assume $PS1 are almost the same as default bashrc
	local -r BASHRC="$HOME/.bashrc"
    local -r INITRC="$HOME/.init.bash"
    local -r BASH_COMPLETION="/etc/profile.d/bash_completion.sh"

    [ -f $BASHRC ] || cp /etc/skel/.bashrc $BASHRC

    local LOAD_CMD=". $BASH_COMPLETION"
    grep -wq "^$LOAD_CMD" $BASHRC ||\
        add_with_sig "$LOAD_CMD" "$BASHRC" "$BASH_NAME"

    LOAD_CMD=". $INITRC"
    grep -wq "^$LOAD_CMD" $BASHRC ||\
        add_with_sig "$LOAD_CMD" "$BASHRC" "$BASH_NAME"
}
