#!/bin/bash
# tmux installer script

source $SHELL_CORE_DIR/utils.sh
source $SHELL_CORE_DIR/sign.sh

TMUX_NAME='tmux'
TMUX_DIR="$SHELL_CONFIG_DIR/$TMUX_NAME"

install() {
    if has_cmd $TMUX_NAME; then
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
    SRC=$TMUX_DIR
    create_link $SRC/tmux.conf .tmux.conf

    # Add load command to bash_completion
    local -r BASH_COMPL="$HOME/.bash_completion"
    local -r BASHRC='.bashrc'
    local LOAD_CMD=''

    SRC=$USR_CONFIG_DIR/bash/completion
    if [ -e $SRC ]; then
        local -r TMUX_COMPL="$TMUX_DIR/completion_tmux"

        pushd $SRC
        create_link $TMUX_COMPL .

        LOAD_CMD="source $TMUX_COMPL\ncomplete -F _tmux tmux"

        #grep -wq "^$LOAD_CMD" $BASH_COMPL ||\
        #    add_with_sig "$LOAD_CMD" "$BASH_COMPL" "$TMUX_NAME"
        popd
    fi

    # Install TPM
    local -r GIT_REPO='https://github.com/tmux-plugins/tpm'
    local -r TPM_DIR="$USR_CONFIG_DIR/$TMUX_NAME/plugins/tpm"
    git clone $GIT_REPO $TPM_DIR
    popd
}
