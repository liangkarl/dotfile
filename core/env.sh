#!/bin/bash

init_env()
{
    local WHERE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. >/dev/null 2>&1 && pwd)}"

    SHELL_LIB_DIR="$WHERE/lib"
    SHELL_CONFIG_DIR="$WHERE/config"
    SHELL_CORE_DIR="$WHERE/core"

    USR_CONFIG_DIR="$HOME/.config"
}
