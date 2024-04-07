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

env.cmd() { type -t "$1"; } &> /dev/null

__init_bash() {

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

    local base

    base="$(dirname $BASH_SOURCE)/base"

    export SYS_OS=$(env.sys)
    export SYS_WSL=$(env.wsl && echo 1 || echo 0)

    # set up XDG_xxx
    source ${base}/xdg.bash

    grep -q -w "${HOME}/bin" <<< "$PATH" || PATH="${HOME}/bin:${PATH}"

    source ${base}/ps1.bash

    eval $(find ${SHELL_DIR}/{completion,ext} -type f -exec 'echo' 'source' '{};' ';')
}

export -f lib.add
export -f path.dup
export -f env.cmd

__init_bash
