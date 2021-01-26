#!/bin/bash

install_full_list()
{
    local INS_LIST=('tmux' 'git' 'bash' 'nvim')

    for NAME in ${INS_LIST[@]}; do
        echo "Install: $NAME"
        install_package $NAME
    done
}

install_package()
{
    local LIB_SCRIPT=$SHELL_LIB_DIR/${1}.sh
    (
        echo "Load $LIB_SCRIPT"
        source $LIB_SCRIPT &&
            install
    )
}
