#!/usr/bin/env bash

[[ -v __SYSTEM_BASH_INCLUDED ]] && return
__SYSTEM_BASH_INCLUDED='none'

__SYSTEM_BASH_BEFORE="$(compgen -A function) $(compgen -v)"

# sys.auto_setup_cmd CMD [PRIORITY]
sys.auto_alter_cmd() {(
    local p n bin

    lib.load devel
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

    lib.load devel
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
    update-alternatives --config $1
}

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
        lib.load devel
        msg.err "failed to load system info (${SYS_INFO})"
    fi
);}

sys.stage_start() {
    local id
    # source.name
    id=${BASH_SOURCE[1]:-root.environment}
    id=$(basename ${id^^})
    id=${id/./_}
    eval "__${id}_BEFORE=\"\$(compgen -A function) \$(compgen -v)\""
}

sys.stage_stop() {
    local id
    # source.name
    id=${BASH_SOURCE[1]:-root.environment}
    id=$(basename ${id^^})
    id=${id/./_}
    eval "__${id}_AFTER=\"\$(compgen -A function) \$(compgen -v)\""
    eval "__${id}_INCLUDED=\$(awk 'NR==FNR {a[\$0]=1; next} !(\$0 in a)' <(printf \"%s\n\" \$__${id}_BEFORE) <(printf \"%s\n\" \$__${id}_AFTER))"
    eval "unset __${id}_AFTER __${id}_BEFORE"
}

sys.stage_reset() {
    local f list id

    id=${1:-root.environment}
    id=$(basename ${id^^})
    id=${id/./_}
    eval "list=\"\${__${id}_INCLUDED}\""
    for f in $list; do
        unset $f || unset -f $f
    done 2> /dev/null

    unset __${id}_INCLUDED
}

__SYSTEM_BASH_AFTER="$(compgen -A function) $(compgen -v)"

# time __SYSTEM_BASH_INCLUDED=$(comm -23 <(printf "%s\n" $' '"$__SYSTEM_BASH_AFTER" | sort) <(printf "%s\n" $' '"$__SYSTEM_BASH_BEFORE" | sort))
# time __SYSTEM_BASH_INCLUDED=$(printf "%s\n" $__SYSTEM_BASH_AFTER | grep -Fvx -f <(printf "%s\n" $__SYSTEM_BASH_BEFORE))
__SYSTEM_BASH_INCLUDED=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__SYSTEM_BASH_BEFORE) <(printf "%s\n" $__SYSTEM_BASH_AFTER))

unset __SYSTEM_BASH_AFTER __SYSTEM_BASH_BEFORE
