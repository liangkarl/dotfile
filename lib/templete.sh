#!/bin/bash

source $SHELL_CORE_DIR/core.sh

XXXX='xxxx'
XXXX_DIR="$SHELL_CONFIG_DIR/$XXXX"

install() {
	has_cmd $XXXX && {
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

uninstall() {
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

config_package() {
	echo "Config $XXXX..."
	echo "Not finished yet..."
}
