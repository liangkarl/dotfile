#!/usr/bin/env bash

[[ -v __LIBRARY_BASH_INCLUDED ]] && return
__LIBRARY_BASH_INCLUDED='none'

sys.stage_start

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
    sys.stage_reset ${1}.bash
}

lib.export() {
    local f list

    eval "list=\"\${__${1^^}_BASH_INCLUDED}\""
    for f in $list; do
        export -f $f || true
    done 2> /dev/null
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

sys.stage_stop
