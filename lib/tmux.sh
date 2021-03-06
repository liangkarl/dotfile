#!/bin/bash
# tmux installer script

source $SHELL_CORE_DIR/core.sh

TMUX='tmux'
TMUX_DIR="$SHELL_CONFIG_DIR/$TMUX"
TPM_DIR="$HOME_CONFIG_DIR/$TMUX/plugins/tpm"

tmux_config_tmux() {
    local BASH_COMPL TMUX_COMPL BASHRC
    local LOAD_CMD SRC

    echo "Config $TMUX..."

    goto $HOME
    SRC=$TMUX_DIR
    link $SRC/tmux.conf .tmux.conf

    # install plugins without openning tmux
    $TPM_DIR/bin/install_plugins

    # Add load command to bash_completion
    BASH_COMPL="$HOME/.bash_completion"
    BASHRC='.bashrc'

    SRC=$HOME_CONFIG_DIR/bash/completion
    if [ -e $SRC ]; then
        TMUX_COMPL="$TMUX_DIR/completion_tmux"

        goto $SRC
        link $TMUX_COMPL .

        LOAD_CMD="source $TMUX_COMPL\ncomplete -F _tmux tmux"

        #grep -wq "^$LOAD_CMD" $BASH_COMPL ||\
        #    add_with_sig "$LOAD_CMD" "$BASH_COMPL" "$TMUX"
        back
    fi
    back
}

tmux_install_tpm() {
    local GIT_REPO

    need_cmd git || return $?

    GIT_REPO='https://github.com/tmux-plugins/tpm'
    goto $HOME
    git clone $GIT_REPO $TPM_DIR
    back
}

tmux_install_tmux() {
    echo "Start installing $TMUX"
    apt_ins $TMUX
}

tmux_remove_tmux() {
    echo "Remove $TMUX..."
    sudo apt purge $TMUX
}

tmux_install() {
    local FORCE
    FORCE="$1"

    echo "Install $TMUX..."
    __take_action $TMUX install $FORCE
    return $?
}

tmux_remove() {
    local FORCE
    FORCE="$1"

	echo "Remove $TMUX..."
    __take_action $TMUX remove $FORCE
    return $?

	# Remove package itself without system configs
	# sudo apt remove $TMUX

	# Remove package itself & system config
	# sudo apt purge $TMUX

	# Remove related dependency
	# sudo apt autoremove
	# still remain user configs
}

tmux_config() {
    local FORCE
    FORCE="$1"

    echo "Configure $TMUX..."
    __take_action $TMUX config $FORCE
    return $?
}

tmux_list() {
    __show_list $TMUX $@
    return $?
}

