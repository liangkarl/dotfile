#!/usr/bin/env bash

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

install_full_list() {
    local INS_LIST FAILED

    INS_LIST=('pack-repos' 'tool-kit' 'bash' 'git' 'tmux' 'nvim')
    for NAME in ${INS_LIST[@]}; do
        echo "======================"
        echo "Install: $NAME"
        echo "======================"
        worker n $NAME i c
    done

    if [ -z $FAILED ]; then
        show_good "install all packages"
    else
        show_hint "$(info_install_failed $FAILED)"
    fi
    return ${#FAILED}
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
