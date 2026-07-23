#!/usr/bin/env bash

export HOSTNAME
export EDITOR=vim

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

# coloring manual
alias man="\
    LESS_TERMCAP_md=$'$(ansi 100)' \
    LESS_TERMCAP_me=$'${_RS}' \
    LESS_TERMCAP_us=$'$(ansi 010)' \
    LESS_TERMCAP_ue=$'${_RS}' \
    LESS_TERMCAP_so=$'$(ansi 002)' \
    LESS_TERMCAP_se=$'${_RS}' \
    man"

if cmd.has update-alternatives; then
    # alias update-alternatives="update-alternatives --altdir $(sys.info ua_altdir) --admindir $(sys.info ua_admdir)"
    update-alternatives() {
        command update-alternatives --altdir $(sys.info ua_altdir) --admindir $(sys.info ua_admdir) "$@"
    }
    export -f update-alternatives
fi

# compression
if cmd.has pxz; then
    alias txz='tar -I pxz -v'
else
    alias txz='tar -Jv'
fi

if cmd.has pigz; then
    alias tgz='tar -I pigz -v'
else
    alias tgz='tar -zv'
fi

if cmd.has pbzip2; then
    alias bz2='tar -I pbzip2 -v'
else
    alias bz2='tar -jv'
fi

if cmd.has bat; then
    export BAT_THEME_DARK="TwoDark"
    # export BAT_THEME="dark"
    alias cat="bat --theme-dark $BAT_THEME_DARK --paging=never --plain"
    alias less="bat --theme-dark $BAT_THEME_DARK --plain"
    alias bat="bat --theme-dark $BAT_THEME_DARK --style=numbers"
fi

if cmd.has delta; then
    alias diff="delta --raw -s"
    alias diff.gen="delta --raw"
else
    alias diff="diff -y"
fi

if cmd.has reboot; then
    # Override reboot command to avoid rebooting computer accidentally
    reboot() {
        echo "If you want to reboot the computer, please try 'builtin reboot'." >&2
    }
fi

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

file() {
    local f args
    # Assume input parameters are commands if they don't exist
    for f in "$@"; do
        if [[ -e "$f" ]]; then
            args+="$f "
        else
            args+="$(which $f) "
        fi
    done

    command file $args
}

# Use for some environment settings failing to link brew libs/cmds
# This function would temporarily remove all possible brew related
# environment settings
# pure_env cmd [args]
pure() {
  local cmd=$(which $1)
  shift
  env -u LDFLAGS -u CPPFLAGS -u PKG_CONFIG_PATH -u LD_LIBRARY_PATH \
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin" \
    $cmd $*
}

android_init() {
    # Generate compile_commands.json
    export SOONG_GEN_COMPDB=1
    export SOONG_GEN_COMPDB_DEBUG=1

    # Make soong generate a symlink to the compdb file using an env var
    # export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT

    # render special file for AOSP in ls
    # binary file: img, bin
    LS_COLORS="*.img=00;93:*.bin=00;93:$LS_COLORS"
    # makefile: mk, bp
    LS_COLORS="*.mk=01;04;35:*.bp=01;04;35:$LS_COLORS"
    # patch: patch, diff
    LS_COLORS="*.patch=01;90:*.diff=01;90:$LS_COLORS"
    # config: json, xml
    LS_COLORS="*.json=00;35:*.xml=00;35:$LS_COLORS"

    # Prevent compilation error of flex in Ubuntu 18.04
    # Fix showing '_' symbols with extension fonts in tmux
    if [[ "$(uname)" == "Darwin" ]]; then
        export LANG=C LC_CTYPE=UTF-8
        # else
        #   FIXME: check whether or not this command is available
        #   The original command is `sudo dpkg-reconfigure locales`
        #
        #   export LC_ALL=C.UTF-8
    fi

    # Quanta
    alias logcat='adb wait-for-device logcat -v color'
    alias kmsg='adb wait-for-device shell dmesg -wr'
}

oneshot android_init
