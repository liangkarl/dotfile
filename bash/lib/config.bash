#!/usr/bin/env bash

[[ -v __CONFIG_BASH_INCLUDED ]] && return
__CONFIG_BASH_INCLUDED='none'

sys.stage_start
lib.load devel

__CONFIG_BASH_DBG=$(dbg.mark)
# dbg.on $__CONFIG_BASH_DBG

# config.set [name] [val]
config.set() {
    local var val
    var=$1; shift
    val="$*"; shift
    eval "__CONFIG_${__CUR_SPACE}_${var}='${val}'"
}

# config.get [o_var] [name] [def]
config.get() {
    local out var def
    out=$1; shift
    var=$1; shift
    def=$1; shift
    eval "$out=\"\${__CONFIG_${__CUR_SPACE}_${var}:-$def}\""
}

# config.del [name]
config.del() {
    local var
    var=$1; shift
    eval "unset __CONFIG_${__CUR_SPACE}_${var}"
}

# config.load [config]
config.load() {
    local tmp space

    [[ "$#" -eq 0 ]] && return 1

    __CUR_SPACE=$(basename $1)
    __CUR_SPACE=${__CUR_SPACE^^}
    __CUR_SPACE=${__CUR_SPACE//./_}

    if [[ ! -e "$1" ]]; then
        __CUR_CONFIG="$*"
        touch $__CUR_CONFIG
        return
    fi

    tmp=$(mktemp)
    __CUR_CONFIG="$*"
    sed -e "/^[^#[:space:]]/s/^/__CONFIG_${__CUR_SPACE}_/" $__CUR_CONFIG > $tmp
    source $tmp
    rm -f $tmp
}

config.dump() {
    local list var

    list=($(set | awk -F'=' "/^__CONFIG_${__CUR_SPACE}_/{print \$1}"))
    for var in "${list[@]}"; do
        if [[ -z "${!var}" ]]; then
            continue
        fi
        echo "${var#__CONFIG_${__CUR_SPACE}_}='${!var}'"
    done
}

# config.save
config.save() {
    if [[ -z "$__CUR_CONFIG" ]]; then
        msg.err "no configuration specified"
        return
    fi

    msg.dbg "save to $__CUR_CONFIG"
    config.dump > $__CUR_CONFIG
    msg.dbg "\n$(cat $__CUR_CONFIG)"
    config.reset
}

# config.reset
config.reset() {
    local list var

    list=($(set | awk -F'=' "/^__CONFIG_${__CUR_SPACE}_/{print \$1}"))
    for var in "${list[@]}"; do
        if [[ -z "${!var}" ]]; then
            continue
        fi
        unset ${var}
    done
    unset __CUR_CONFIG
}

# config.sort
config.sort() {
    local tmp

    tmp=$(mktemp)
    cp -f $__CUR_CONFIG $tmp
    cat $tmp | sort > $__CUR_CONFIG
    rm -f $tmp
}

sys.stage_stop
