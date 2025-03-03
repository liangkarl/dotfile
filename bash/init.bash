#!/usr/bin/env bash

# Load LIB into current shell environment
# lib.add LIB
lib.add() {
    [[ ! -e "$SHELL_DIR" ]] && lib.devel msg.err "invalid \$SHELL_DIR"
    source "$SHELL_DIR/lib/${1}.bash"
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
#dbg.on

msg.dbg "load: $(source.name)"

# Order:
# source bash/env/00_pre-env.bash;
# source bash/env/11_xdg.bash;
# source bash/env/12_ps1.bash;
# ...
eval $(find ${SHELL_DIR}/init -type f -exec 'echo' 'source' '{};' ';' | sort)

msg.dbg "path: $PATH"
msg.dbg "$(source.name): completed"
dbg.off

devel.clean
