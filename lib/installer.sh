#!/bin/bash

INSTALL_PACKAGES_LIST=(
        'tmux'
        'git'
        'bash'
)

install_packages()
{
        local len=${#INSTALL_PACKAGES_LIST[@]}
        local package=

        for((i = 0; i < len; i++)); do
                package=${INSTALL_PACKAGES_LIST[$i]}
                echo "Package: $package"
                load_and_install_package $package
        done
}

load_and_install_package()
{
        local script=${1}.sh
        (
                echo "Load script of package"
                source $LIB_DIR/$script
                install
        )
}
