#!/bin/bash
# tmux installer script

source $CORE_DIR/utils.sh
source $CORE_DIR/sign.sh

TMUX_NAME='tmux'
TMUX_CONFIG="$CONFIG_DIR/$TMUX_NAME"
USR_CONFIG="$HOME/.config"

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
    local SRC=''

    pushd $HOME
    SRC=$TMUX_CONFIG
    create_link $SRC/tmux.conf .tmux.conf

    # Add load command to bash_completion
    local -r BASH_COMPL="$HOME/.bash_completion"
    local -r BASHRC='.bashrc'
    local LOAD_CMD=''

    SRC=$USR_CONFIG/bash/completion
    if [ -e $SRC ]; then
        local -r TMUX_COMPL="$TMUX_CONFIG/completion_tmux"

        pushd $SRC
	create_link $TMUX_COMPL .

        LOAD_CMD="source $TMUX_COMPL\ncomplete -F _tmux tmux"

        #grep -wq "^$LOAD_CMD" $BASH_COMPL ||\
        #    add_with_sig "$LOAD_CMD" "$BASH_COMPL" "$TMUX_NAME"
    fi

    # Install TPM
    local -r GIT_REPO='https://github.com/tmux-plugins/tpm'
    local -r TPM_DIR="$USR_CONFIG/$TMUX_NAME/plugins/tpm"
    git clone $GIT_REPO $TPM_DIR
    popd
}

# tmux-continuum

# tmux-yank

# Tmux Resurrect

# Tmux sensible
