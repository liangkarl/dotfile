#!/usr/bin/env bash

__SYSTEM_BASH_FUNCS_BEFORE="$(compgen -A function) $(compgen -v)"

lib.load devel

# sys.auto_setup_cmd CMD
sys.auto_alter_cmd() {
    local p n bin

    bin=$(sys.info bin)/$1
    n=300
    for p in $(which -a $1); do
        [[ "$p" == "$bin" ]] && continue
        msg.info "add: $p $n"
        sys.alter_cmd $1 "$p" $n || msg.err "failed"
        n=$((n - 10))
    done
}

# sys.alter_cmd CMD LOCATION [PRIORITY]
sys.alter_cmd() {
    local pr path

    path=$(path.abs $2)
    pr=${3:-300}
    if [[ ! -e "$path" ]]; then
        msg.err "cannot found: $path"
        return 1
    fi

    update-alternatives --install $(sys.info bin)/$1 $1 $2 $pr
}

# sys.config_cmd CMD
sys.config_cmd() {
    update-alternatives --config $1
}

__SYSTEM_BASH_FUNCS_AFTER="$(compgen -A function) $(compgen -v)"

# Remove duplicated path. The duplicated words in the end would be removed
sys.reload_path() {
    PATH=$(echo -n $PATH | awk 'BEGIN {RS=":"; ORS=":"} !a[$0]++')
    PATH=${PATH%:}
}

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

if [[ -n "$__SYSTEM_BASH_FUNCS_DIFF" ]]; then
    msg.dbg "$(source.name): use old diff table"
else
    # time __SYSTEM_BASH_FUNCS_DIFF=$(comm -23 <(printf "%s\n" $' '"$__SYSTEM_BASH_FUNCS_AFTER" | sort) <(printf "%s\n" $' '"$__SYSTEM_BASH_FUNCS_BEFORE" | sort))
    # time __SYSTEM_BASH_FUNCS_DIFF=$(printf "%s\n" $__SYSTEM_BASH_FUNCS_AFTER | grep -Fvx -f <(printf "%s\n" $__SYSTEM_BASH_FUNCS_BEFORE))
    __SYSTEM_BASH_FUNCS_DIFF=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__SYSTEM_BASH_FUNCS_BEFORE) <(printf "%s\n" $__SYSTEM_BASH_FUNCS_AFTER))
fi
unset __SYSTEM_BASH_FUNCS_AFTER __SYSTEM_BASH_FUNCS_BEFORE
