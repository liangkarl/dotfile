#!/usr/bin/env bash

export SYS_INFO="${SHELL_DIR}/info"

lib.add() {
    [[ ! -e "$SHELL_DIR" ]] && lib.devel msg.err "invalid \$SHELL_DIR"
    source "$SHELL_DIR/lib/${1}.bash"
}

lib.space() {
    local f l
    list=${1:-$(ls $SHELL_DIR/lib)}
    for f in $list; do
        eval "lib.${f%.bash}() { (lib.add ${f%.bash}; eval \"\$*\"); }"
    done
}

export -f lib.add lib.space

sys.__init() {(
    get_sys_name() {
        sw_vers -productName || \
            lsb_release -i -s
    }

    lib.add config

    [[ -e "${SYS_INFO}" ]] && return

    system=$(get_sys_name)
    system=${system,,}
    config_load ${SYS_INFO}
    config_set system "${system}$([[ -n "$WSL_DISTRO_NAME" ]] && echo ':wsl')"
    config_set my_bin "${HOME}/.local/bin"
    config_save
);}

# sys.info var [VAL]
sys.info() {(
    if [[ -e "${SYS_INFO}" ]]; then
        if [[ -z "$2" ]]; then
            source ${SYS_INFO}
            echo "${!1}"
        else
            lib.add config
            config_reset
            config_load ${SYS_INFO}
            config_set "$1" "$2"
            config_save
        fi
    else
        msg.err "failed to load system info (${SYS_INFO})"
    fi
);}

# Remove duplicated path. The duplicated words in the end would be removed
sys.reload_path() {
    PATH=$(echo -n $PATH | awk 'BEGIN {RS=":"; ORS=":"} !a[$0]++')
    PATH=${PATH%:}
}

sys.__init
