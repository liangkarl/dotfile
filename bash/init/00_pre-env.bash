#!/usr/bin/env bash

export SYS_INFO="${SHELL_DIR}/info"
msg.dbg "SYS_INFO: $SYS_INFO"

# Read/Write system info database
# sys.info var [VAL]
sys.info() {(
    if [[ -e "${SYS_INFO}" ]]; then
        if [[ -z "$2" ]]; then
            source ${SYS_INFO}
            echo "${!1}"
        else
            lib.add config
            config.reset
            config.load ${SYS_INFO}
            config.set "$1" "$2"
            config.save
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

bash_init() {
    if [[ ! -e "${SYS_INFO}" ]]; then (
        lib.add config
        system=$(cmd.try "sw_vers -productName" "lsb_release -i -s")
        system=${system,,}
        config.load ${SYS_INFO}
        config.set system "${system}$([[ -n "$WSL_DISTRO_NAME" ]] && echo ':wsl')"
        config.set my_bin "${HOME}/.local/bin"
        config.save
        msg.dbg "$SYS_INFO:"
        msg.dbg "$(cat $SYS_INFO)"
    ) fi

    unset -f bash_init
}

bash_init
