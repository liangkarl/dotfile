#!/usr/bin/env bash

configure_fuzzy_finder() {

    if cmd.has fzf; then
        local binds

        msg.dbg "configure fzf"
        # Default options
        # export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"
        eval "$(fzf --bash 2> $__N)"

        # Default command to use when input is tty
        # Now fzf (w/o pipe) will use fd instead of find
        export FZF_DEFAULT_COMMAND='fd --type f'

        # To apply the command to CTRL-T as well
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

        binds="ctrl-d:half-page-down,"
        binds+="ctrl-u:half-page-up,"
        binds+="ctrl-s:toggle-sort,"
        binds+="ctrl-p:toggle-preview,"
        binds+="ctrl-a:first,"
        binds+="ctrl-e:last,"
        binds+="ctrl-c:cancel,"
        binds+="ctrl-t:toggle-track"
        # Hide the preview window at beginning and keep empty preview command to
        # avoid conflict to the preview command setting from other apps
        # `toggle-track` is only available after fzf 0.40
        export FZF_DEFAULT_OPTS="--ansi
                --bind '$binds'
                --preview-window=':hidden,wrap'
                --preview='echo -- Full String --; echo {}; if [[ -f {} ]]; then echo; echo -- File Preview --; head {}; fi'
                --keep-right
                --reverse
                --color='hl:1:underline,hl+:1:underline' --inline-info"

    elif cmd.has fzy; then
        __fzy_history__() {
            local output script
            # script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
            output=$(
                builtin fc -lnr -2147483648 |
                sed 's/^[[:space:]]*//' |
                fzy -i --query "$READLINE_LINE"
            ) || return
            READLINE_LINE=${output#*$'\t'}
            if [[ -z "$READLINE_POINT" ]]; then
                echo "$READLINE_LINE"
            else
                READLINE_POINT=0x7fffffff
            fi
        }

        msg.dbg "configure fzy"
        # bind -x '"\C-r":"history | fzy -i"'
        bind -m emacs-standard -x '"\C-r": __fzy_history__'
        bind -m vi-command -x '"\C-r": __fzy_history__'
        bind -m vi-insert -x '"\C-r": __fzy_history__'
    fi
}

configure_glib() {
    export LD_LIBRARY_PATH="/lib/x86_64-linux-gnu"
    export LD_LIBRARY_PATH="$(brew --prefix glibc)/lib:${LD_LIBRARY_PATH}"
}

configure_enhancd() {
    local enhancd

    enhancd=${XDG_CONFIG_HOME}/enhancd
    if [[ -e "$enhancd" ]]; then
        source ${enhancd}/init.sh
    fi
}

configure_update_alternative() {
    export DPKG_ADMINDIR="$(sys.info ua_altdir)"
}

# oneshot configure_glib
oneshot configure_update_alternative
oneshot configure_fuzzy_finder
oneshot configure_enhancd
