#!/usr/bin/env bash

source ${XDG_CONFIG_HOME}/bash/prompt-completion.bash


# ---------------------------------------------------------

# Delete backward: stop at whitespace, words, or symbols
_word_delete_back() {
    local left=${READLINE_LINE:0:READLINE_POINT}
    local right=${READLINE_LINE:READLINE_POINT}
    local match

    [[ -z $left ]] && return

    if [[ $left =~ [[:space:]]+$ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $left =~ [[:alnum:]_]+$ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $left =~ [^[:alnum:]_[:space:]]+$ ]]; then
        match=${BASH_REMATCH[0]}
    else
        return
    fi

    READLINE_POINT=$((${#left} - ${#match}))
    READLINE_LINE=${left:0:READLINE_POINT}$right
}

# Delete forward: stop at whitespace, words, or symbols
_word_delete_forward() {
    local left=${READLINE_LINE:0:READLINE_POINT}
    local right=${READLINE_LINE:READLINE_POINT}
    local match

    [[ -z $right ]] && return

    if [[ $right =~ ^[[:space:]]+ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $right =~ ^[[:alnum:]_]+ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $right =~ ^[^[:alnum:]_[:space:]]+ ]]; then
        match=${BASH_REMATCH[0]}
    else
        return
    fi

    READLINE_LINE=$left${right:${#match}}
    READLINE_POINT=${#left}
}

# Key bindings
bind -x '"\e\177": _word_delete_back'
bind -x '"\ed": _word_delete_forward'
