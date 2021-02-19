#!/bin/bash

source $SHELL_CORE_DIR/core.sh

XXXX='xxxx'
XXXX_DIR="$SHELL_CONFIG_DIR/$XXXX"

xxxx_install() {
    local FORCE
    FORCE="$1"

    echo "Install $XXXX..."
    install_exector $XXXX "${XXXX}_install_" $FORCE
    return $GOOD
}

xxxx_remove() {
    local FORCE
    FORCE="$1"

	echo "Remove $XXXX..."
    install_exector $XXXX "${XXXX}_remove_" $FORCE
    return $GOOD

	# Remove package itself without system configs
	# sudo apt remove $XXXX

	# Remove package itself & system config
	# sudo apt purge $XXXX

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

xxxx_config() {
    local FORCE
    FORCE="$1"

    echo "Configure $XXXX..."
    install_exector $XXXX "${XXXX}_config_" $FORCE
}

xxxx_list() {
    install_lister $XXXX $@
}
