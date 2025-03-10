#!/usr/bin/env bash

dbg.cmd "export SYS_INFO=\"${BASH_CFG}/info\""

# Read/Write system info database
# sys.info var [VAL]
sys.info() {(
    if [[ -e "${SYS_INFO}" ]]; then
        if [[ -z "$2" ]]; then
            source ${SYS_INFO}
            echo "${!1}"
        else
            lib.load config
            config.reset
            config.load ${SYS_INFO}
            config.set "$1" "$2"
            config.save
        fi
    else
        msg.err "failed to load system info (${SYS_INFO})"
    fi
);}
export -f sys.info

# Remove duplicated path. The duplicated words in the end would be removed
sys.reload_path() {
    PATH=$(echo -n $PATH | awk 'BEGIN {RS=":"; ORS=":"} !a[$0]++')
    PATH=${PATH%:}
}

bash_init() {
    if ! cmp -s ${SYS_INFO} ${SYS_INFO}.last; then (
        lib.load config

        config.load ${SYS_INFO}
        config.get system system
        if [[ -z "$system" ]]; then
            system=$(cmd.try "sw_vers -productName" "lsb_release -i -s")
            system=${system,,}
            config.set system "${system}$([[ -n "$WSL_DISTRO_NAME" ]] && echo ':wsl')"
        fi

        config.get bin bin
        if [[ -z "$bin" ]]; then
            config.set bin "${HOME}/.local/bin"
        fi

        config.save
        cp $SYS_INFO ${SYS_INFO}.last

        msg.dbg "$SYS_INFO:"
        msg.dbg "$(cat $SYS_INFO)"
    ) fi
    unset -f $FUNCNAME
}

bash_init
