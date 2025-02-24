# config_set [name] [val]
config_set() {
    local var val
    var=$1; shift
    val="$*"; shift
    eval "__CONFIG_BASH_${var}='${val}'"
}

# config_get [o_var] [name] [def]
config_get() {
    local out var def
    out=$1; shift
    var=$1; shift
    def=$1; shift
    eval "$out=\"\${__CONFIG_BASH_${var}:-$def}\""
}

# config_del [name]
config_del() {
    local var
    var=$1; shift
    eval "unset __CONFIG_BASH_${var}"
}

# config_load [config]
config_load() {
    local tmp

    [[ "$#" -eq 0 ]] && return 1

    if [[ ! -e "$1" ]]; then
        __config="$*"
        touch $__config
        return
    fi

    tmp=$(mktemp)
    __config="$*"
    sed -e '/^[^#[:space:]]/s/^/__CONFIG_BASH_/' $__config > $tmp
    source $tmp
    rm -f $tmp
}

config_dump() {
    local list var

    list=($(set | awk -F'=' '/^__CONFIG_BASH_/{print $1}'))
    for var in "${list[@]}"; do
        if [[ -z "${!var}" ]]; then
            continue
        fi
        echo "${var#__CONFIG_BASH_}='${!var}'"
    done
}

# config_save
config_save() {
    config_dump > $__config
    config_reset
}

# config_reset
config_reset() {
    local list var

    list=($(set | awk -F'=' '/^__CONFIG_BASH_/{print $1}'))
    for var in "${list[@]}"; do
        if [[ -z "${!var}" ]]; then
            continue
        fi
        unset ${var}
    done
    unset __config
}

# config_sort
config_sort() {
    local tmp

    tmp=$(mktemp)
    cp -f $__config $tmp
    cat $tmp | sort > $__config
    rm -f $tmp
}

# TODO:
# config_export
