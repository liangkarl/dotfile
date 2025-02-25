#!/usr/bin/env bash

env.cmd() { type -t "$1"; } &> /dev/null

env.wsl() { [[ -n "$WSL_DISTRO_NAME" ]]; }

env.sys() {
    local os

    if env.cmd sw_vers; then
        os="$(sw_vers -productName)" # 'macOS'
        os="${os/macOS/Mac}"         # 'Mac'
    elif env.cmd lsb_release; then
        os="$(lsb_release -i -s)"    # 'Ubuntu'
    fi

    echo $os
} 2> /dev/null

export -f env.cmd
export -f env.wsl
export -f env.sys

export SYS_OS=$(env.sys)
export SYS_WSL=$(env.wsl && echo 1 || echo 0)
