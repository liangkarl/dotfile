#!/bin/bash

__prepare__() {
    local SHELL_DIR
    SHELL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    source $SHELL_DIR/core/base.sh
    init_env $SHELL_DIR
    source $SHELL_DIR/core/installer.sh
}

__prepare__
unset __prepare__
