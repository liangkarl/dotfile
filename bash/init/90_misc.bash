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

ln() {
    local cmd opt dst
    local src ab_src oldpwd i

    cmd=()
    src=()
    ab_src=()
    for opt in "$@"; do
        if [[ -e "$opt" ]]; then
            src+=($opt)
            ab_src+=($(realpath $opt))
        fi
    done

    dst=${src[$((${#src[@]}-1))]}

    i=0
    oldpwd=$OLDPWD
    for opt in "$@"; do
         # skip last elm (dst)
        if [[ $i -ne $((${#src[@]}-1)) ]]; then
            # check if src path appeared
            if [[ "$opt" == "${src[$i]}" ]]; then
                # check src path availability
                if builtin cd $dst || builtin cd $(dirname $dst); then
                    if [[ ! -e "${opt}" ]]; then
                        echo "replace: ${opt} -> ${ab_src[$i]}"
                        opt=${ab_src[$i]}
                    fi
                    builtin cd $OLDPWD
                fi 2> /dev/null
                i=$((i + 1))
            fi
        fi
        cmd+=($opt)
    done

    if [[ -n "$oldpwd" ]]; then
        OLDPWD=$oldpwd
    else
        unset OLDPWD
    fi

    $(which ln) "${cmd[@]}"
}

export HOSTNAME
export EDITOR=vim
