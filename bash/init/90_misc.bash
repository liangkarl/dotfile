#!/usr/bin/env bash

# process
alias psa='ps -elf'

# list files
alias ls='ls -v --group-directories-first -N --color=auto'
alias ll='ls -l --time-style=long-iso'
alias la='ls -a'
alias tree='tree --dirsfirst -h'
alias l='ll'

# misc
alias cls='clear'
alias rsync='rsync -av -h --progress'
alias less='less -R'
# alias update-alternatives="update-alternatives --altdir $(sys.info ua_altdir) --admindir $(sys.info ua_admdir)"
update-alternatives() {
    command update-alternatives --altdir $(sys.info ua_altdir) --admindir $(sys.info ua_admdir) "$@"
}
export -f update-alternatives

# compression
if [[ -n "$(type -p pxz)" ]]; then
    alias txz='tar -I pxz -v'
else
    alias txz='tar -Jv'
fi

if [[ -n "$(type -p pigz)" ]]; then
    alias tgz='tar -I pigz -v'
else
    alias tgz='tar -zv'
fi

if [[ -n "$(type -p pbzip2)" ]]; then
    alias bz2='tar -I pbzip2 -v'
else
    alias bz2='tar -jv'
fi

if [[ -n "$(type -p bat)" ]]; then
    export BAT_THEME_DARK="TwoDark"
    export BAT_THEME="dark"
    alias cat="$(which bat) --theme-dark $BAT_THEME_DARK --paging=never --plain"
    alias bat="$(which bat) --theme-dark $BAT_THEME_DARK --style=numbers"
fi

# coloring manual
alias man="\
    LESS_TERMCAP_md=$'$(ansi 100)' \
    LESS_TERMCAP_me=$'${_RS}' \
    LESS_TERMCAP_us=$'$(ansi 010)' \
    LESS_TERMCAP_ue=$'${_RS}' \
    LESS_TERMCAP_so=$'$(ansi 002)' \
    LESS_TERMCAP_se=$'${_RS}' \
    man"

# Override reboot command to avoid rebooting computer accidentally
reboot() {
    echo "If you want to reboot the computer, please try 'builtin reboot'." >&2
}

kill.contain() {
    if [[ -z "$1" ]]; then
        echo "kill the process including its children"
        return 1
    fi
    kill $(ps -s $1 -o pid=);
}

ln.abs() {
    local dst=$(eval "echo \$$#")
    local cmd linkdir opt

    if [[ -d "$dst" ]]; then
        linkdir="$dst"
    elif [[ -e "$dst" || ! "$dst" =~ */ ]]; then
        linkdir=$(dirname "$dst")
    else
        echo "not a valid directory or file: $dst" >&2
        return 2
    fi

    for i in $(seq 1 $#); do
        opt="$(eval "echo \${$i}")"

        if [[ -e "$opt" && $i -ne "$#" ]]; then
            cmd+="$(realpath "$opt") "
        else
            cmd+="$opt "
        fi
    done

    ln $cmd
}

ln.rlt() {
    ln -r "$@"
}

################################################################################
# man.vim
# Arguments:
#     $n: command names
# Outputs:
#     open manuals with vim
# Returns:
#     return nvim exit values
################################################################################
man.vim() {
    local rm_empty="-c 'bufdo if empty(bufname()) | bdelete | endif'"
    local cmd="nvim "

    if [ $# -ne 0 ]; then
        cmd+="-c 'Man $1 | only' "
        shift
    fi

    if [ $# -ne 0 ]; then
        for c in "$@"; do
            cmd+="-c 'tabnew' -c 'Man $c | only' "
        done
    fi
    cmd+=$rm_empty

    eval $cmd
}

export HOSTNAME
export EDITOR=vim
