#!/usr/bin/env bash

source $SHELL_CORE_DIR/core.sh

GDB='gdb'
GDB_DIR="$SHELL_CONFIG_DIR/$GDB"

gdb_install_gdb()
{
    apt_ins $GDB
}

gdb_install_gdbgui() {
    need_cmd python3 || return $?

    pip3_ins pipx
    [ -z "$(echo $PATH | grep $HOME_BIN_DIR)" ] &&
        python3 -m userpath append $HOME_BIN_DIR

    # For debian-based OS
    apt_ins python3-venv

    pipx install gdbgui
}

gdb_config_gdbinit() {
    need_cmd wget pip || return $?

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
    __take_action $GDB install $FORCE
    return $?
}

gdb_remove() {
    local FORCE
    FORCE="$1"

	echo "Remove $GDB..."
    __take_action $GDB remove $FORCE
    return $?
}

gdb_config() {
    local FORCE
    FORCE="$1"

    echo "Configure $GDB..."
    __take_action $GDB config $FORCE
    return $?
}

gdb_list() {
    __show_list $GDB $@
    return $?
}
