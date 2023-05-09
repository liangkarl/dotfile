#!/usr/bin/env bash

__fzy_history__() {
    local output script
    script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
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

# TODO: check primary fuzzy finder
if ! type -t fzf; then
    if type -t fzy; then
        # bind -x '"\C-r":"history | fzy -i"'
        bind -m emacs-standard -x '"\C-r": __fzy_history__'
        bind -m vi-command -x '"\C-r": __fzy_history__'
        bind -m vi-insert -x '"\C-r": __fzy_history__'
    fi
fi > /dev/null
