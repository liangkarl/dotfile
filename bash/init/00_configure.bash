#!/usr/bin/env bash

dbg.cmd "export SYS_INFO=\"${BASH_CFG}/info\""

if ! cmp -s ${SYS_INFO} ${SYS_INFO}.last; then (
    load config

    config.load ${SYS_INFO}
    config.get system system
    if [[ -z "$system" ]]; then
        system=$(cmd.try "sw_vers -productName" "lsb_release -i -s")
        system=${system,,}
        config.set system "${system}$([[ -n "$WSL_DISTRO_NAME" ]] && echo ':wsl')"
    fi

    config.get bin bin
    if [[ -z "$bin" ]]; then
        config.set bin "$LOCAL_BIN"
    fi

    config.get altdir ua_altdir
    if [[ -z "$altdir" ]]; then
        config.set ua_altdir "${HOME}/.local/etc/alternatives"
    fi

    config.get admdir ua_admdir
    if [[ -z "$admdir" ]]; then
        config.set ua_admdir "${HOME}/.local/etc/alternatives-admin"
    fi

    config.save
    cp $SYS_INFO ${SYS_INFO}.last

    msg.dbg "$SYS_INFO:"
    msg.dbg "$(cat $SYS_INFO)"
) fi

# PROMPT_COMMAND=""
force_cursor_bar() { printf '\e[?25h\e[5 q'; }
alias fixcursor='stty sane; force_cursor_bar; clear'

# Force set cursor everytime as the application may not recover it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;force_cursor_bar}"

# ---------- Bash History: best-practice setup ----------

# 1) Large history
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTFILE="$HOME/.bash_history"

# 2) Ignore duplicates & optionally ignore commands starting with a space
# - ignoreboth = ignorespace + ignoredups
# - erasedups  = remove older duplicates, keep the most recent
export HISTCONTROL=ignoreboth:erasedups

# 3) Append rather than overwrite
shopt -s histappend

# 4) Save multi-line commands as a single entry (optional but nice)
shopt -s cmdhist

# 5) Timestamp each history entry (optional but very useful)
export HISTTIMEFORMAT='%F %T  '

# 6) Optional: ignore some noisy commands (tune to your taste)
# & means "same as previous command"
HISTIGNORE="&:ls:cd:pwd:exit:clear"

# 7) IMPORTANT: live sync history across multiple terminals
# - history -a : append new lines from this session to HISTFILE
# - history -n : read new lines from HISTFILE into this session
# - history -w : write out the current history list (after erasedups effects)
# Use a small guard to avoid spamming errors in restricted shells.
# __hist_sync() {
#   builtin history -a
# }
# PROMPT_COMMAND="__hist_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

export GIT_COMPLETION_SHOW_ALL_COMMANDS=1
