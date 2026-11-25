#!/usr/bin/env bash

[[ -v __DEBUG_BASH_INCLUDED ]] && return
__DEBUG_BASH_INCLUDED='none'

__bash_env_record_begin

__DBG_ALL='__global__'
__DEBUG_BASH_CUR_SPACE_LIST=()

# File spaces are identified by basename. Global debugging enables every file.
# dbg.space [SPACE] prints the space name for use with dbg.on and dbg.off.
dbg.space() {
    local id=${1:-${BASH_SOURCE[1]##*/}}
    printf '%s\n' "$id"
}

# dbg.file [FILE]: append debug messages to FILE as well as stdout.
# With no FILE, stop writing to the debug file.
dbg.file() {
    __DBG_FILE=${1:-}
}

dbg.on() {
    local space=${1:-$__DBG_ALL} item
    for item in "${__DEBUG_BASH_CUR_SPACE_LIST[@]}"; do
        [[ "$item" == "$space" ]] && return 0
    done
    __DEBUG_BASH_CUR_SPACE_LIST+=("$space")
}

dbg.off() {
    local space=${1:-$__DBG_ALL} item
    local -a remaining=()
    local found=1
    for item in "${__DEBUG_BASH_CUR_SPACE_LIST[@]}"; do
        if [[ "$item" == "$space" ]]; then
            found=0
        else
            remaining+=("$item")
        fi
    done
    __DEBUG_BASH_CUR_SPACE_LIST=("${remaining[@]}")
    return "$found"
}

msg.dbg() {
    local id=${BASH_SOURCE[${__DBG_IDX:-1}]##*/} item enabled=
    for item in "${__DEBUG_BASH_CUR_SPACE_LIST[@]}"; do
        if [[ "$item" == "$id" || "$item" == "$__DBG_ALL" ]]; then
            enabled=1
            break
        fi
    done
    [[ -n "$enabled" ]] || return 0
    if [[ -n "${__DBG_FILE:-}" ]]; then
        printf 'DEBUG: %s: %s\n' "$id" "$*" | tee -a -- "$__DBG_FILE"
    else
        printf 'DEBUG: %s: %s\n' "$id" "$*"
    fi
}

dbg.cmd() {
    __DBG_IDX=2 msg.dbg "$*"
    eval "$*"
}

dbg.cmd_stop() {
    __DBG_IDX=2 msg.dbg "$*"
    eval "$*" || exit $?
}

dbg.dumpstack() {
    local trace="" cmdline parent
    local cp=${1:-$$}

    while [[ "$cp" =~ ^[0-9]+$ && -r "/proc/$cp/status" ]]; do
        cmdline=$(tr '\0' ' ' < "/proc/$cp/cmdline") || return 1
        parent=$(awk '/^PPid:/ { print $2 }' "/proc/$cp/status") || return 1
        trace="$trace [$cp]:$cmdline\n"
        [[ "$cp" == 1 || "$parent" == 0 ]] && break
        [[ -n "$parent" && "$parent" != "$cp" ]] || return 1
        cp=$parent
    done
    [[ -n "$trace" ]] || return 1
    printf "Backtrace of '%s'\n" "$0"
    printf '%b' "$trace" | tac | grep -n ":"
}

__bash_env_record_end
