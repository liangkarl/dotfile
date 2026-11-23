#!/usr/bin/env bash

[[ -v __SYSTEM_BASH_INCLUDED ]] && return
__SYSTEM_BASH_INCLUDED='none'

__bash_env_record_begin

# sys.auto_setup_cmd CMD [PRIORITY]
sys.auto_alter_cmd() {(
    local p n bin

    load devel
    if [[ $# -eq 0 ]]; then
        echo "$FUNCNAME CMD [PRIORITY]"
        return 1
    fi
    bin=$(sys.info bin)/$1
    n=${2:-300}
    for p in $(which -a $1); do
        [[ "$p" == "$bin" ]] && continue
        msg.info "add: $p (pr:$n)"
        sys.alter_cmd $1 "$p" $n || msg.err "failed"
        n=$((n - 10))
    done
)}

# sys.alter_cmd CMD LOCATION [PRIORITY]
sys.alter_cmd() {(
    local pr path

    if [[ $# -eq 0 ]]; then
        echo "$FUNCNAME CMD LOCATION [PRIORITY]"
        return 1
    fi
    load devel
    path=$(path.abs $2)
    pr=${3:-300}
    if [[ ! -e "$path" ]]; then
        msg.err "cannot found: $path"
        return 1
    fi

    update-alternatives --install $(sys.info bin)/$1 $1 $2 $pr
)}

# sys.config_cmd CMD
sys.config_cmd() {
    if [[ $# -eq 0 ]]; then
        echo "$FUNCNAME CMD"
        return 1
    fi
    update-alternatives --config $1
}

# Read/Write system info database
# sys.info var [VAL]
sys.info() {(
    if [[ -e "${SYS_INFO}" ]]; then
        if [[ -z "$1" ]]; then
            cat ${SYS_INFO}
        elif [[ -z "$2" ]]; then
            source ${SYS_INFO}
            echo "${!1}"
        else
            load config
            config.reset
            config.load ${SYS_INFO}
            config.set "$1" "$2"
            config.save
        fi
    else
        load devel
        msg.err "failed to load system info (${SYS_INFO})"
    fi
);}

__bash_env_record_end
