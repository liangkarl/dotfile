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
    python3 -m userpath append $HOME_BIN_DIR
    pipx install gdbgui
}

gdb_install()
{
    local FORCE ALL
    FORCE=$(echo $1 | grep force)
    ALL=$(declare -F | awk '{print $3}' | grep -E "^${GDB}_install_")

    [ -z $FORCE ] && {
        has_cmd $GDB || break

		show_hint "$(info_installed $GDB)"
		return
	}

	echo "Install $GDB..."
    for EXEC in $ALL; do
        $EXEC
    done
}

gdb_remove()
{
	echo "Remove $GDB..."
	echo "Not finished yet..."
}

gdb_config()
{
    local FORCE ALL
    FORCE=$(echo $1 | grep force)
    ALL=$(declare -F | awk '{print $3}' | grep -E "^${GIT}_config_")

    [ -z $FORCE ] && {
        has_cmd $GIT || break

		show_hint "$(info_installed $GIT)"
		return
	}

    echo "Config $GIT..."
    for EXEC in $ALL; do
        $EXEC
    done
}

gdb_config_gdbinit()
{
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
