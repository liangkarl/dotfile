# config_set name val
config_set() {
    local var val
    var=$1; shift
    val="$*"; shift
    eval "export __CONFIG_BASH_${var}='${val}'"
}

# config_get o_var name def
config_get() {
    local out var def
    out=$1; shift
    var=$1; shift
    def=$1; shift
    eval "$out=\"\${__CONFIG_BASH_${var}:-$def}\""
}

# config_load conf
config_load() {
    local tmp

    if [[ ! -e "$1" ]]; then
        __config="$*"
        touch $__config
        return
    fi

    tmp=$(mktemp)
    __config="$*"
    sed -e '/^[^#[:space:]]/s/^/export __CONFIG_BASH_/' $__config > $tmp
    source $tmp
    rm -f $tmp
}

config_save() {
    local list var tmp

    tmp="$(mktemp)"
    list=($(env | awk -F'=' '/^__CONFIG_BASH_/{print $1}'))
    for var in "${list[@]}"; do
        if [[ -z "${!var}" ]]; then
            continue
        fi
        echo "${var#__CONFIG_BASH_}='${!var}'" >> $tmp
    done

    cat $tmp > $__config
    rm -f $tmp

    config_reset
}

config_reset() {
    local list var

    list=($(env | awk -F'=' '/^__CONFIG_BASH_/{print $1}'))
    for var in "${list[@]}"; do
        unset ${var}
    done
    unset __config
}

config_sort() {
    local tmp

    tmp=$(mktemp)
    cp -f $__config $tmp
    cat $tmp | sort > $__config
    rm -f $tmp
}
