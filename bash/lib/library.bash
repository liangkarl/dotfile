#!/usr/bin/env bash

__LIBRARY_BASH_FUNCS_BEFORE="$(compgen -A function) $(compgen -v)"

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

# Load LIB into current shell environment
export -f lib.load lib.space

if [[ -n "$__LIBRARY_BASH_FUNCS_DIFF" ]]; then
    msg.dbg "$(source.name): use old diff table"
else
    # time __LIBRARY_BASH_FUNCS_DIFF=$(comm -23 <(printf "%s\n" $' '"$__LIBRARY_BASH_FUNCS_AFTER" | sort) <(printf "%s\n" $' '"$__LIBRARY_BASH_FUNCS_BEFORE" | sort))
    # time __LIBRARY_BASH_FUNCS_DIFF=$(printf "%s\n" $__LIBRARY_BASH_FUNCS_AFTER | grep -Fvx -f <(printf "%s\n" $__LIBRARY_BASH_FUNCS_BEFORE))
    __LIBRARY_BASH_FUNCS_DIFF=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__LIBRARY_BASH_FUNCS_BEFORE) <(printf "%s\n" $__LIBRARY_BASH_FUNCS_AFTER))
fi
unset __LIBRARY_BASH_FUNCS_AFTER __LIBRARY_BASH_FUNCS_BEFORE
