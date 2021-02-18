#!/bin/bash

source $SHELL_CORE_DIR/core.sh

GDB='gdb'
GDB_DIR="$SHELL_CONFIG_DIR/$GDB"

gdb_install_guigdb()
{
	local NEED_PACK

    NEED_PACK='wget pip'
	has_cmd $NEED_PACK || {
        show_err "$(info_req_cmd $NEED_PACK)"
		return $BAD
	}

    goto $HOME
    wget -P ~ https://git.io/.gdbinit
    pip install pygments
    back
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
	echo "Config $GDB..."
	echo "Not finished yet..."
}
