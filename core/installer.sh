#!/bin/bash

. $SHELL_CORE_DIR/core.sh

install_full_list() {
    local INS_LIST FAILED

    INS_LIST=('pack-repos' 'bash' 'git' 'tmux' 'nvim')
    for NAME in ${INS_LIST[@]}; do
        echo "======================"
        echo "Install: $NAME"
        echo "======================"
        install_from_script $NAME || {
            FAILED+=" $NAME"
        }
    done

    if [ -z $FAILED ]; then
        show_good "install all packages"
    else
        show_hint "$(info_install_failed $FAILED)"
    fi
    return ${#FAILED}
}

install_from_script() {
    local LIB_SCRIPT

    LIB_SCRIPT=$SHELL_LIB_DIR/${1}.sh
    source $LIB_SCRIPT && {
        echo "Loaded $LIB_SCRIPT"
        install
        return $?
    }

    show_err "Failed to load $LIB_SCRIPT"
    return $BAD
}

install_from_sources() {
    local SOURCE CMD
    CMD="$1"
    shift
    SOURCE=($@)

    for SRC in ${SOURCE[@]}; do
        install_from_${SRC}
        has_cmd $CMD && {
            show_good "Install $CMD successfully"
            return $GOOD
        }
        echo "Try installing $CMD from $SRC failed"
    done

    show_err "$(info_install_failed $CMD)"
    return $BAD
}

add_ppa_repo() {
    local NAME NEED_CMD
    NAME="$1"
    NEED_CMD='add-apt-repository'
    has_cmd $NEED_CMD || {
        show_err "$(info_req_cmd $NEED_CMD)"
        return $BAD
    }
    # install_if_no add-apt-repository software-properties-common
    sudo add-apt-repository -y $NAME
    sudo apt update
    return $GOOD
}

install_exector() {
    local FORCE ALL FUNC CMD

    CMD="$1"
    FUNC="$2"
    FORCE=$(echo $3 | grep force)
    ALL=$(declare -F | awk '{print $3}' | grep -E "^$FUNC")

    [ -z $FORCE ] && {
        has_cmd $CMD && return $BAD

        show_hint "$(info_installed $CMD)"
        return $BAD
    }

    for EXEC in $ALL; do
        $EXEC
    done
}

install_lister() {
    local NAME

    NAME="$1"
    shift

    while [ $# -ne 0 ]; do
        case $1 in
            c|-c|--config)
                echo "List config available function(s) as below"
                declare -F | awk '{print $3}' | grep -E "^${NAME}_config"
                ;;
            i|-i|--install)
                echo "List install available function(s) as below"
                declare -F | awk '{print $3}' | grep -E "^${NAME}_install"
                ;;
            r|-r|--remove)
                echo "List remove available function(s) as below"
                declare -F | awk '{print $3}' | grep -E "^${NAME}_remove"
                ;;
            *)
                show_err "not support option '$1'"
        esac
        shift
        echo ""
    done
}

__help_install() {
    cat << USAGE
SYNOPSIS:
$1 [n|-n|--name ...] [i|-i|--install] [r|-r|--remove] [c|-c|--config] [f|-f|--force]
$1 [l|-l|--list [install | remove | config]]
$1 [h|-h|--help]

EXAMPLE:
  $1 n bash i c #install and config bash
  $1 n bash f i #force install bash
  $1 n bash l i #list available install function(s) in bash.sh
USAGE
}

worker() {
    local CMD ARGS NAME HELP ALL RET

    [ $# -eq 0 ] && {
        __help_install $FUNCNAME
        return $GOOD
    }

    ALL="$(ls -p $SHELL_LIB_DIR | grep -v / | sed 's/\.sh//g')"
    while :; do
        [ $# -eq 0 ] && break
		case $1 in
            n|-n|--name)
                shift
                NAME="$(echo -e $ALL | grep "$1")"
                if [ -z "$1" ]; then
                    NAME=''
                else
                    NAME="$1"
                fi
                ;;
			f|-f|--force)
                ARGS=force
				;;
            r|-r|--remove)
                CMD+=' remove'
                ;;
            i|-i|--install)
                CMD+=' install'
                ;;
            c|-c|--config)
                CMD+=' config'
                ;;
            l|-l|--list)
                CMD='list'
                ARGS=''
                shift
                while :; do
                    [ -z "$1" ] && break 2
                    ARGS+=" $1"
                    shift
                done
                ;;
            h|-h|--help)
                __help_install $FUNCNAME
				return $GOOD
                ;;
			*)
                __help_install $FUNCNAME
				return $BAD
		esac
        shift
	done

    RET=$GOOD
    if [ -z "$NAME" ]; then
        show_err "Require package name as below:"
        show_hint "$ALL\n"
        RET=$BAD
    fi

    if [ -z "$CMD" ]; then
        __help_install $FUNCNAME
        RET=$BAD
    fi

    if [ $RET -eq $BAD ]; then
        return $RET
    fi

    source $SHELL_LIB_DIR/${NAME}.sh

    for ACTION in $CMD; do
        has_cmd ${NAME}_${ACTION} || {
            show_hint "$NAME: Not support or implement $ACTION yet."
            continue
        }
        ${NAME}_${ACTION} $ARGS
    done
    return $GOOD
}
