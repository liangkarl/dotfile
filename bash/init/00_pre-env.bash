#!/usr/bin/env bash

dbg.cmd "export SYS_INFO=\"${BASH_CFG}/info\""

oneshot() {
    eval "$*"
    unset -f "$1"
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

        config.get altdir ua_altdir
        if [[ -z "$altdir" ]]; then
            config.set ua_altdir "${HOME}/.local/etc/alternatives"
        fi

        config.get admdir ua_admdir
        if [[ -z "$admdir" ]]; then
            config.set ua_admdir "${HOME}/.local/etc/alternatives-admin"
        fi

        config.save
        cp $SYS_INFO ${SYS_INFO}.last

        msg.dbg "$SYS_INFO:"
        msg.dbg "$(cat $SYS_INFO)"
    ) fi
}

oneshot bash_init
