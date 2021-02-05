#!/bin/bash

__install__() {
    local ROOT

    SHELL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source $SHELL_DIR/core/env.sh
    source $SHELL_DIR/core/installer.sh

    # prepare basic functions
    init_env $SHELL_DIR

    # Install package
    install_full_list
}

__install__
