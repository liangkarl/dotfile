#!/bin/bash

source $SHELL_CORE_DIR/core.sh

XXXX='xxxx'
XXXX_DIR="$SHELL_CONFIG_DIR/$XXXX"

xxxx_install() {
    local FORCE
    FORCE=$(echo $1 | grep force)

    [ -z $FORCE ] && {
        has_cmd $XXXX || break

		show_hint "$(info_installed $XXXX)"
		return
	}

	local NEED_PACK='

	'
	has_cmd "$NEED_PACK" || {
		show_err "$(info_req_cmd $NEED_PACK)"
		return
	}

	echo "Install $XXXX..."
	echo "Not finished yet..."
	# config_package
}

xxxx_remove() {
	echo "Remove $XXXX..."
	echo "Not finished yet..."

	# Remove package itself without system configs
	# sudo apt remove $XXXX

	# Remove package itself & system config
	# sudo apt purge $XXXX

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

xxxx_config() {
	echo "Config $XXXX..."
	echo "Not finished yet..."
}

xxxx_list() {
    while :; do
        [ -z "$1" ] && break
        echo "List $1's available function(s) as below"
        case $1 in
            c|-c|--config)
                declare -F | awk '{print $3}' | grep -E "^${XXXX}_config"
                ;;
            i|-i|--install)
                declare -F | awk '{print $3}' | grep -E "^${XXXX}_install"
                ;;
            r|-r|--remove)
                declare -F | awk '{print $3}' | grep -E "^${XXXX}_remove"
                ;;
            *)
                show_err "not support option '$1'"
        esac
        shift
        echo ""
    done
}
