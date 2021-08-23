#!/bin/bash
# tmux installer script

# source $SHELL_CORE_DIR/core.sh

tmux_install() {
    local url='https://github.com/tmux/tmux.git'
    local pos="/tmp/install/tmux"

    if [[ ! -z "$(type -p tmux)" ]]; then
        echo "you have install tmux already"
        exit 2
    fi

    PS3='select install source > '
    select option in 'github' 'apt' 'cancel'; do
        case $option in
            github) # https://github.com/tmux/tmux

                # remove install dir
                trap 'rm -rf $pos' EXIT

                # download git
                git clone --depth=1 $url $pos

                # build tmux
                cd $pos
                sh autogen.sh
                ./configure
                make
                sudo make install
                cd -

                ;;
            apt)
                sudo apt install tmux
                ;;
            cancel)
                exit 0
                ;;
        esac
    done

    echo "install complete"
}

usage() {
    echo "$(basename $0) [install]"
}

trap 'echo "operation failed ($?)"' ERR
set -eE

if (( $# == 0 )); then
    usage
    exit 1
fi

while (( $# != 0 )); do
    case $1 in
        install)
            tmux_install
            ;;
        remove)
            tmux_remove
            ;;
        *)
            break
    esac
done
