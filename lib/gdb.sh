#!/bin/bash

source $SHELL_CORE_DIR/core.sh

GDB='gdb'
GDB_DIR="$SHELL_CONFIG_DIR/$GDB"

gdb_install_gdb()
{
    sudo apt install -y $GDB
}

gdb_install_gdbgui()
{
    local NEED_CMD

    NEED_CMD=python3

	has_cmd $NEED_CMD || {
        show_err "$(info_req_cmd $NEED_CMD)"
		return $BAD
	}

    python3 -m pip install --user pipx
    [ -z "$(echo $PATH | grep $HOME_BIN_DIR)" ] &&
        python3 -m userpath append $HOME_BIN_DIR

    # For debian-based OS
    sudo apt install python3-venv

    pipx install gdbgui
}

gdb_config_gdbinit() {
	local NEED_CMD

    NEED_CMD='wget pip'
	has_cmd $NEED_CMD || {
        show_err "$(info_req_cmd $NEED_CMD)"
		return $BAD
	}

	echo "Config $GDB..."
    goto $HOME
    wget -P ~ https://git.io/.gdbinit
    pip install pygments
    back
}

gdb_install() {
    local FORCE
    FORCE="$1"

    echo "Install $GDB..."
    __take_action $GDB "${GDB}_install_" $FORCE
    return $GOOD
}

gdb_remove() {
    local FORCE
    FORCE="$1"

	echo "Remove $GDB..."
    __take_action $GDB "${GDB}_remove_" $FORCE
    return $GOOD
}

gdb_config() {
    local FORCE
    FORCE="$1"

    echo "Configure $GDB..."
    __take_action $GDB "${GDB}_config_" $FORCE
}

gdb_list() {
    __show_list $GDB $@
}
