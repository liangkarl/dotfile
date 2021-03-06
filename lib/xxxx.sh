#!/bin/bash

source $SHELL_CORE_DIR/core.sh

XXXX='xxxx'
XXXX_DIR="$SHELL_CONFIG_DIR/$XXXX"
# XXXX_IS_GROUP=y

xxxx_cleanup() {
    LIST="
        XXXX
        XXXX_DIR
        xxxx_install
        xxxx_remove
        xxxx_config
        xxxx_list
        $FUNCNAME
    "
    for NAME in $LIST; do
        unset $NAME
    done
}

xxxx_install() {
    local ARGS
    ARGS="$1"

    echo "Install $XXXX..."
    __take_action $XXXX install $ARGS
    return $?
}

xxxx_remove() {
    local ARGS
    ARGS="$1"

	echo "Remove $XXXX..."
    __take_action $XXXX remove $ARGS
    return $?

	# Remove package itself without system configs
	# sudo apt remove $XXXX

	# Remove package itself & system config
	# sudo apt purge $XXXX

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

xxxx_config() {
    local ARGS
    ARGS="$1"

    echo "Configure $XXXX..."
    __take_action $XXXX config $ARGS
    return $?
}

xxxx_list() {
    __show_list $XXXX $@
    return $?
}
