#!/bin/bash

source $SHELL_CORE_DIR/core.sh

TOOLKIT='tool-kit'
TOOLKIT_DIR="$SHELL_CONFIG_DIR/$TOOLKIT"


tool-kit_install_all() {
    local LIST
    LIST=("p7zip-full" "zip" "tree")
    apt_ins ${LIST[@]}

    LIST=("fd-find")
    npm_ins_g ${LIST[@]}

    LIST=("fd*.deb" "ripgrep*.deb")
    deb_ins ${LIST[@]}
}


tool-kit_install() {
    local ARGS
    ARGS="$1"

    echo "Install $TOOLKIT..."
    __take_action $TOOLKIT install $ARGS
    return $?
}

tool-kit_remove() {
    local ARGS
    ARGS="$1"

	echo "Remove $TOOLKIT..."
    __take_action $TOOLKIT remove $ARGS
    return $?

	# Remove package itself without system configs
	# sudo apt remove $TOOLKIT

	# Remove package itself & system config
	# sudo apt purge $TOOLKIT

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

tool-kit_config() {
    local ARGS
    ARGS="$1"

    echo "Configure $TOOLKIT..."
    __take_action $TOOLKIT config $ARGS
    return $?
}

tool-kit_list() {
    __show_list $TOOLKIT $@
    return $?
}
