#!/usr/bin/env bash

export BASH_CFG="$(dirname ${BASH_SOURCE[0]})"

# Load LIB into current shell environment
# lib.add LIB
lib.add() {
    local lib

    lib="${BASH_CFG}/lib/${1}.bash"
    if [[ ! -e "$lib" ]]; then
        echo "$FUNCNAME: library not found: $lib" >&2
        return 1
    fi

    source $lib
}

# lib.off LIB
lib.off() {
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
        eval "lib.${f%.bash}() { (lib.add ${f%.bash}; eval \"\$*\"); }"
    done
}

export -f lib.add lib.space

# for debug
lib.add devel
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

lib.off devel
