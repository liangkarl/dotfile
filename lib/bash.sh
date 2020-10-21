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

        ## Modify $PS1
        # Assume $PS1 are almost the same as default bashrc
        local -r BASHRC="$HOME/.bashrc"
        local -r BASHRC_TMP="${BASHRC}.tmp"
        if [ -e $BASHRC ]; then
                # Show current dir only, not full path.
                sed 's:\\w\\:\\W\\:g' $BASHRC > $BASHRC_TMP

                if ! cmp $BASHRC $BASHRC_TMP; then
                        echo "Backup $BASHRC"
                        mv $BASHRC ${BASHRC}.bak

                        echo "Replace $BASHRC"
                        mv $BASHRC_TMP $BASHRC
                fi

                rm $BASHRC_TMP
        fi
}
