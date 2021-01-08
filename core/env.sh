#!/bin/bash

init_env()
{
    local WHERE="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. >/dev/null 2>&1 && pwd)"
    local DIR="$1"
    if [ -z "$DIR" ]; then
        SHELL_LIB_DIR="$WHERE/lib"
        SHELL_CONFIG_DIR="$WHERE/config"
        SHELL_CORE_DIR="$WHERE/core"
    else
        SHELL_LIB_DIR="$DIR/lib"
        SHELL_CONFIG_DIR="$DIR/config"
        SHELL_CORE_DIR="$DIR/core"
    fi
}
