#!/usr/bin/env bash

# Load LIB into current shell environment
# lib.add LIB
lib.add() {
    [[ ! -e "$SHELL_DIR" ]] && echo 'invalid $SHELL_DIR' >&2
    source "$SHELL_DIR/lib/${1}.bash"
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
    local f l
    list=${1:-$(ls $SHELL_DIR/lib)}
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
source.dir "${SHELL_DIR}/init"

msg.dbg "path: $PATH"
msg.dbg "completed"
dbg.off

lib.off devel
