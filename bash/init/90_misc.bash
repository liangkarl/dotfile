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
# (don't append space in the end of 'man')
alias man=" \
	LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[45;93m' \
    LESS_TERMCAP_se=$'\e[0m' \
    man\
"

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
