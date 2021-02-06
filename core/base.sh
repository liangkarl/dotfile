#!/bin/bash

init_env() {
    local DEFAULT DIR

    DEFAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. >/dev/null 2>&1 && pwd)"
    DIR="${1:-$DEFAULT}"

    SHELL_LIB_DIR="$DIR/lib"
    SHELL_CONFIG_DIR="$DIR/config"
    SHELL_CORE_DIR="$DIR/core"
    SHELL_BIN_DIR="$DIR/bin"

    HOME_CONFIG_DIR="$HOME/.config"

    GOOD=0
    BAD=1
}
