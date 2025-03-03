#!/usr/bin/env bash

msg.dbg "load: $(source.name)"

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

bash_init() {
    if [[ ! -e "${SYS_INFO}" ]]; then (
        lib.add config
        system=$(cmd.try "sw_vers -productName" "lsb_release -i -s")
        system=${system,,}
        config_load ${SYS_INFO}
        config_set system "${system}$([[ -n "$WSL_DISTRO_NAME" ]] && echo ':wsl')"
        config_set my_bin "${HOME}/.local/bin"
        config_save
        msg.dbg "$SYS_INFO:"
        msg.dbg "$(cat $SYS_INFO)"
    ) fi

    unset -f bash_init
}

bash_init
