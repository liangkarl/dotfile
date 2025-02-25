#!/usr/bin/env bash

# FIXME:
# WA for brew toolchain issue

lib.add() {
    local file

    file="${1}.bash"
    if [[ -z "$SHELL_DIR" ]]; then
        echo "$SHELL_DIR wasn't defined"
        return 1
    elif [[ ! -e "$SHELL_DIR" ]]; then
        echo "'$SHELL_DIR' wasn't existed"
        return 2
    elif [[ -z "$1" ]]; then
        echo "Empty input"
        return 3
    elif [[ ! -e "$SHELL_DIR/lib/${file}" ]]; then
        echo "'$1' doesn't exist"
        return 4
    fi

    source "$SHELL_DIR/lib/${file}"
}

path.dup() {
    # Remove duplicated path
    PATH=$(echo -n $PATH | awk 'BEGIN {RS=":"; ORS=":"} !a[$0]++')
    PATH=${PATH%:}
}

path.brew() {
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

path.nvm() {
	export NVM_DIR="$HOME/.config/nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

export -f lib.add
export -f path.dup
