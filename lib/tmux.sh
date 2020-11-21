#!/bin/bash
# tmux installer script

source $CORE_DIR/utils.sh
source $CORE_DIR/sign.sh

TMUX_NAME='tmux'
TMUX_CONFIG="$CONFIG_DIR/$TMUX_NAME"

install() {
    if test_cmd $TMUX_NAME; then
        echo "$TMUX_NAME is already installed"
    else
        echo "Start installing $TMUX_NAME"
        sudo apt install -y $TMUX_NAME
        config_package
    fi
}

uninstall() {
    echo "Remove $TMUX_NAME..."
    sudo apt purge $TMUX_NAME
}

config_package() {
    echo "Config $TMUX_NAME..."

    ## Create config link
    local -r DST_CONFIG='.tmux.conf'
    local -r SRC_CONFIG='tmux.conf'
    create_link $TMUX_CONFIG/$SRC_CONFIG $HOME/$DST_CONFIG

    ## Add autocomplete for bash
    local -r DST_BASH="$HOME/.bash_completion"
    local -r SRC_BASH="$TMUX_CONFIG/bash_completion"

    # Add load command to bash_completion
    local -r LOAD_CMD="source $SRC_BASH\ncomplete -F _tmux tmux"

    init_sign $TMUX_NAME "$LOAD_CMD"

    if [ -z $DST_BASH ]; then
        touch $DST_BASH
    else
        cp $DST_BASH ${DST_BASH}.bak
    fi
    append_sign_and_content $DST_BASH

    # Install TPM
    local -r GIT_REPO="https://github.com/tmux-plugins/tpm"
    local -r TPM_DIR="~/.tmux/plugins/tpm"
    git clone $GIT_REPO $TPM_DIR
}

# tmux-continuum

# tmux-yank

# Tmux Resurrect

# Tmux sensible
