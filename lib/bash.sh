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

    [ -f $BASHRC ] || cp /etc/skel/.bashrc $BASHRC

    echo -e "\nif [ -f $BASHRC ]; then\n	. $INITRC\nfi\n\n" >> $BASHRC
}
