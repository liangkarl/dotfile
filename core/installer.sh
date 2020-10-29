#!/bin/bash

# TODO:
# Need to implement 'ccls', 'bear', 'others'
declare -r INSTALL_PACKAGES_LIST=(
        'tmux'
        'git'
        'bash'
        'nvim'
)

install_packages()
{
        local LEN=${#INSTALL_PACKAGES_LIST[@]}
        local PACKAGE_NAME=

        for((i = 0; i < LEN; i++)); do
                PACKAGE_NAME=${INSTALL_PACKAGES_LIST[$i]}
                echo "Install $((i+1)) : $PACKAGE_NAME"
                load_and_install_package $PACKAGE_NAME
        done
}

load_and_install_package()
{
        local -r PACKAGE_NAME=$1
        local LIB_SCRIPT=$LIB_DIR/${1}.sh
        (
                echo "Load \"$PACKAGE_NAME\" script"
                source $LIB_SCRIPT &&
                        install
        )
}
