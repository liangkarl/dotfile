#!/bin/bash

. $SHELL_CORE_DIR/core.sh

install_full_list() {
    local INS_LIST

    INS_LIST=('tmux' 'git' 'bash' 'nvim' 'pack-repos')
    for NAME in ${INS_LIST[@]}; do
        echo "======================"
        echo "Install: $NAME"
        echo "======================"
        install_from_script $NAME
    done

    echo "install all packages"
}

install_from_script() {
    local LIB_SCRIPT

    LIB_SCRIPT=$SHELL_LIB_DIR/${1}.sh
    source $LIB_SCRIPT && {
        echo "Loaded $LIB_SCRIPT"
        install
        return
    }

    show_err "Failed to load $LIB_SCRIPT"
}

install_from_sources() {
    local SOURCE CMD
    CMD="$1"
    shift
    SOURCE=($@)

    for SRC in ${SOURCE[@]}; do
        install_from_${SRC}
        has_cmd $CMD && {
            show_good "Install $CMD successfully"
            return $GOOD
        }
        echo "Try installing $CMD from $SRC failed"
    done

    show_err "$(info_install_failed $CMD)"
    return $BAD
}

add_ppa_repo() {
    local NAME NEED_CMD
    NAME="$1"
    NEED_CMD='add-apt-repository'
    has_cmd $NEED_CMD || {
        show_err "$(info_req_cmd $NEED_CMD)"
        return 128
    }
    # install_if_no add-apt-repository software-properties-common
    sudo add-apt-repository $NAME
    sudo apt update
}

install_option() {
    for ARGV in "$@"; do
		case "$ARGV" in
			f|-f|--force)
				;;
			h|-h|--help)
				;;
            u|-u|--uninstall)
                ;;
            c|-c|--config)
                ;;
			*)
                [ $# -eq 0 ] && {
                    install
                }
				return 128
		esac
	done
}
