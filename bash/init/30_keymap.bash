#!/usr/bin/env bash

source ${XDG_CONFIG_HOME}/bash/prompt-completion.bash

# ---------------------------------------------------------

# Move backward by word, whitespace, or symbol
_word_move_back() {
    local left=${READLINE_LINE:0:READLINE_POINT}
    local match

    if [[ $left =~ [[:space:]]+$ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $left =~ [[:alnum:]_]+$ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $left =~ [^[:alnum:]_[:space:]]+$ ]]; then
        match=${BASH_REMATCH[0]}
    else
        return
    fi

    READLINE_POINT=$((READLINE_POINT - ${#match}))
}

# Move forward by word, whitespace, or symbol
_word_move_forward() {
    local right=${READLINE_LINE:READLINE_POINT}
    local match

    if [[ $right =~ ^[[:space:]]+ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $right =~ ^[[:alnum:]_]+ ]]; then
        match=${BASH_REMATCH[0]}
    elif [[ $right =~ ^[^[:alnum:]_[:space:]]+ ]]; then
        match=${BASH_REMATCH[0]}
    else
        return
    fi

    READLINE_POINT=$((READLINE_POINT + ${#match}))
}

# Move backward by whitespace-separated WORD
_bigword_move_back() {
    local LC_ALL=C
    local left=${READLINE_LINE:0:READLINE_POINT}

    if [[ $left =~ [^[:space:]]*[[:space:]]*$ ]]; then
        READLINE_POINT=$((READLINE_POINT - ${#BASH_REMATCH[0]}))
    fi
}

# Move forward by whitespace-separated WORD
_bigword_move_forward() {
    local LC_ALL=C
    local right=${READLINE_LINE:READLINE_POINT}

    if [[ $right =~ ^[[:space:]]*[^[:space:]]* ]]; then
        READLINE_POINT=$((READLINE_POINT + ${#BASH_REMATCH[0]}))
    fi
}

# Mark region for Readline kill-region
_mark_region() {
    local point=$READLINE_POINT

    "$@"

    READLINE_MARK=$READLINE_POINT
    READLINE_POINT=$point
}

# Character navigation
bind '"\eh": backward-char'                  # alt + h
bind '"\el": forward-char'                   # alt + l

# History navigation
bind '"\ej": next-history'                   # alt + j
bind '"\ek": previous-history'               # alt + k

# Undo
bind '"\ez": undo'
bind '"\ev": yank'

# Word navigation (segment)
bind -x '"\e[1;3D": _word_move_back'         # alt + LT
bind -x '"\e[1;3C": _word_move_forward'      # alt + RT
bind -x '"\eb": _word_move_back'             # alt + b
bind -x '"\ew": _word_move_forward'          # alt + w

# WORD navigation (whitespace-separated)
bind -x '"\e[1;4D": _bigword_move_back'      # alt + shift + LT
bind -x '"\e[1;4C": _bigword_move_forward'   # alt + shift + RT
bind -x '"\eB": _bigword_move_back'          # alt + B
bind -x '"\eW": _bigword_move_forward'       # alt + W
# bind -x '"\e[1;5D": _bigword_move_back'      # ctrl + LT
# bind -x '"\e[1;5C": _bigword_move_forward'   # ctrl + RT
# bind -x '"\C-b": _bigword_move_back'         # ctrl + b
# bind -x '"\C-w": _bigword_move_forward'      # ctrl + w

# Internal bindings for kill-region
bind -x '"\e[9001~": _mark_region _word_move_back'
bind -x '"\e[9002~": _mark_region _word_move_forward'
bind -x '"\e[9003~": _mark_region _bigword_move_forward'
bind    '"\e[9004~": kill-region'

# Word deletion (segment)
bind '"\e\177":  "\e[9001~\e[9004~"'   # alt + BS
bind '"\e[3;3~": "\e[9002~\e[9004~"'   # alt + DEL
bind '"\ed":     "\e[9002~\e[9004~"'   # alt + d

# WORD deletion (whitespace-separated)
bind '"\e[127;4u": unix-word-rubout'    # alt + shift + BS
bind '"\e[3;4~": "\e[9003~\e[9004~"'   # alt + shift + DEL
bind '"\eD":     "\e[9003~\e[9004~"'   # alt + D

# Line deletion (kill)
bind '"\C-u": unix-line-discard'
bind '"\C-k": kill-line'
