#!/usr/bin/env bash

configure_apps() {
    local cmd

    # HomeBrew
    for cmd in "/home/linuxbrew/.linuxbrew/bin/brew" "/opt/homebrew/bin/brew"; do
        [[ -e "$cmd" ]] && eval $($cmd shellenv)
    done

    # NVM
    if [[ -e "${HOME}/.config/nvm" ]]; then
        export NVM_DIR="$HOME/.config/nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    fi
}

configure_apps
