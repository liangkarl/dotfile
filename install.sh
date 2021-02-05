#!/bin/bash

__help__() {
    cat <<\
RAW
$(basename $0) [-h]
-h: print help
RAW
}

__prepare__() {
    local SHELL_DIR
    SHELL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    source $SHELL_DIR/core/base.sh
    init_env $SHELL_DIR
    source $SHELL_DIR/core/installer.sh
}

__main__() {
    while :; do
        case $1 in
            -h)
                __help__
                exit $GOOD
                ;;
            -?* | ?*) # invaild string
                __help__
                exit $BAD
                ;;
            *)  # no var
                install_full_list
                exit $GOOD
        esac
    done
}

__prepare__
__main__ "$@"
