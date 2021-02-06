#!/bin/bash
# tmux installer script

source $SHELL_CORE_DIR/utils.sh
source $SHELL_CORE_DIR/sign.sh

TMUX='tmux'
TMUX_DIR="$SHELL_CONFIG_DIR/$TMUX"

config_package() {
    local BASH_COMPL TMUX_COMPL BASHRC
    local LOAD_CMD SRC

    echo "Config $TMUX..."

    pushd $HOME
    SRC=$TMUX_DIR
    create_link $SRC/tmux.conf .tmux.conf

    # Add load command to bash_completion
    BASH_COMPL="$HOME/.bash_completion"
    BASHRC='.bashrc'

    SRC=$HOME_CONFIG_DIR/bash/completion
    if [ -e $SRC ]; then
        TMUX_COMPL="$TMUX_DIR/completion_tmux"

        pushd $SRC
        create_link $TMUX_COMPL .

        LOAD_CMD="source $TMUX_COMPL\ncomplete -F _tmux tmux"

        #grep -wq "^$LOAD_CMD" $BASH_COMPL ||\
        #    add_with_sig "$LOAD_CMD" "$BASH_COMPL" "$TMUX"
        popd
    fi
    popd
}

install_tpm() {
    local GIT_REPO TPM_DIR
    GIT_REPO='https://github.com/tmux-plugins/tpm'
    TPM_DIR="$HOME_CONFIG_DIR/$TMUX/plugins/tpm"

    has_cmd git || {
        show_err "$(info_req_cmd git)"
        return
    }

    pushd $HOME
    git clone $GIT_REPO $TPM_DIR
    popd
}

install() {
    has_cmd $TMUX && {
        show_hint "$(info_installed $TMUX)"
        return
    }

    echo "Start installing $TMUX"
    sudo apt install -y $TMUX
    config_package
    install_tpm
}

uninstall() {
    echo "Remove $TMUX..."
    sudo apt purge $TMUX
}

