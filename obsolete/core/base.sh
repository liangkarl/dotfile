#!/usr/bin/env bash

init_env() {
    local DEFAULT DIR

    DEFAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. >/dev/null 2>&1 && pwd)"
    DIR="${1:-$DEFAULT}"
    FAILED_CMD=''

    SHELL_LIB_DIR="$DIR/lib"
    SHELL_CONFIG_DIR="$DIR/config"
    SHELL_CORE_DIR="$DIR/core"
    SHELL_BIN_DIR="$DIR/bin"
    SHELL_DEB_DIR="$DIR/etc/linux/deb"

    HOME_CONFIG_DIR="$HOME/.config"
    HOME_BIN_DIR="$HOME/bin"

    GOOD=0
    BAD=1
}
