if type -t fzf; then
    # Default options
    # export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"

    # Default command to use when input is tty
    # Now fzf (w/o pipe) will use fd instead of find
    export FZF_DEFAULT_COMMAND='fd --type f'

    # To apply the command to CTRL-T as well
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # Hide the preview window at beginning and keep empty preview command to
    # avoid conflict to the preview command setting from other apps
    export FZF_DEFAULT_OPTS="--ansi --track
            --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-s:toggle-sort,ctrl-p:toggle-preview'
            --preview-window=':hidden,nowrap'
            --color='hl:1:underline,hl+:1:underline' --inline-info"

elif type -t fzy; then
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

    # bind -x '"\C-r":"history | fzy -i"'
    bind -m emacs-standard -x '"\C-r": __fzy_history__'
    bind -m vi-command -x '"\C-r": __fzy_history__'
    bind -m vi-insert -x '"\C-r": __fzy_history__'
fi > /dev/null
