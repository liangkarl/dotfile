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
