#!/usr/bin/env bash

export BASH_CFG="$(dirname ${BASH_SOURCE[0]})"

# Load LIB into current shell environment
# lib.load LIB
lib.load() {
    local lib

    lib="${BASH_CFG}/lib/${1}.bash"
    if [[ ! -e "$lib" ]]; then
        echo "$FUNCNAME: library not found: $lib" >&2
        return 1
    fi

    source $lib
}

# lib.unload LIB
lib.unload() {
    local f list

    eval "list=\"\${__${1^^}_BASH_FUNCS_DIFF}\""
    for f in $list; do
        unset $f || unset -f $f
    done 2> /dev/null

    unset __${id}_FUNCS_DIFF
}

lib.export() {
    local f list

    eval "list=\"\${__${1^^}_BASH_FUNCS_DIFF}\""
    for f in $list; do
        export -f $f
    done
}

# Load all or specific LIB without sourcing them in current shell environment
# lib.space [LIB]
lib.space() {
    local f
    list=${1:-$(ls ${BASH_CFG}/lib)}
    for f in $list; do
        f=${f%.bash}
        eval "${f}.cmd() { (lib.load ${f}; eval \"\$*\"); }"
        eval "${f}.unload() { unset -f '${f}.cmd' '${f}.unload'; }"
    done
}

export -f lib.load lib.space

# for debug
lib.load devel
# dbg.on

# Order:
# source bash/env/00_pre-env.bash;
# source bash/env/11_xdg.bash;
# source bash/env/12_ps1.bash;
# ...
source.dir "${BASH_CFG}/init"

msg.dbg "path: $PATH"
msg.dbg "completed"
dbg.off

lib.unload devel
