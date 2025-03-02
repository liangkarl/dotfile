#!/usr/bin/env bash

# config_set [name] [val]
config_set() {
    local var val
    var=$1; shift
    val="$*"; shift
    eval "__CONFIG_${__CUR_SPACE}_${var}='${val}'"
}

# config_get [o_var] [name] [def]
config_get() {
    local out var def
    out=$1; shift
    var=$1; shift
    def=$1; shift
    eval "$out=\"\${__CONFIG_${__CUR_SPACE}_${var}:-$def}\""
}

# config_del [name]
config_del() {
    local var
    var=$1; shift
    eval "unset __CONFIG_${__CUR_SPACE}_${var}"
}

# config_load [config]
config_load() {
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

config_dump() {
    local list var

    list=($(set | awk -F'=' "/^__CONFIG_${__CUR_SPACE}_/{print \$1}"))
    for var in "${list[@]}"; do
        if [[ -z "${!var}" ]]; then
            continue
        fi
        echo "${var#__CONFIG_${__CUR_SPACE}_}='${!var}'"
    done
}

# config_save
config_save() {
    config_dump > $__CUR_CONFIG
    config_reset
}

# config_reset
config_reset() {
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

# config_sort
config_sort() {
    local tmp

    tmp=$(mktemp)
    cp -f $__CUR_CONFIG $tmp
    cat $tmp | sort > $__CUR_CONFIG
    rm -f $tmp
}

# TODO:
# config_export
