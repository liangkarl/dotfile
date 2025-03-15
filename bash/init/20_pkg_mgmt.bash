#!/usr/bin/env bash

configure_package_management() {
    local cmd

    # HomeBrew
    for cmd in "/home/linuxbrew/.linuxbrew/bin/brew" "/opt/homebrew/bin/brew"; do
        if [[ -e "$cmd" ]]; then
            msg.dbg "found: $cmd"
            eval $($cmd shellenv)
        fi
    done

    # NVM
    if [[ -e "${HOME}/.config/nvm" ]]; then
        msg.dbg "found: NVM configuration"
        export NVM_DIR="$HOME/.config/nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    fi

    msg.dbg "path change: $PATH"

}

oneshot configure_package_management
