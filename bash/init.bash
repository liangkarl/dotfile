#!/usr/bin/env bash

oneshot() {
    eval "$*"
    unset -f "$1"
}

xdg_init() {
    # XDG Base Directory Specification
    # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
    # https://wiki.archlinux.org/title/XDG_Base_Directory
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
    export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
}

ext_init() {
    local init_order d tmp
    init_order=(
        "homebrew"
        "rustup"
        "pyenv"
        "pipx"
        "nvm"
        "yarn"
        "starship"
        "broot"
        "enhancd"
    )

    tmp="$(mktemp)"
    for d in "${init_order[@]}"; do
        if [[ -e "${XDG_CONFIG_HOME}/${d}/bootstrap.sh" ]]; then
            msg.dbg "init ${d}"
            cat "${XDG_CONFIG_HOME}/${d}/bootstrap.sh" >> $tmp
            echo "" >> $tmp
        else
            msg.dbg "not found ${d}"
        fi
    done

    source "$tmp"
}

export BASH_CFG="$(dirname ${BASH_SOURCE[0]})"

# This first call of library should be source
source ${BASH_CFG}/lib/system.bash
source ${BASH_CFG}/lib/library.bash
lib.export system
lib.export library

# for debug
lib.load devel
lib.load ansi
dbg.on

oneshot xdg_init
oneshot ext_init

# Order:
# source bash/env/00_pre-env.bash;
# source bash/env/11_xdg.bash;
# source bash/env/12_ps1.bash;
# ...
source "${BASH_CFG}/full-init.bash"
dbg.cmd "sys.add_path '$(sys.info bin)'"

msg.dbg "path: $PATH"
msg.dbg "completed"
dbg.off

lib.unload ansi
lib.unload devel
