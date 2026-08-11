#!/usr/bin/env bash

dbg.cmd "export SYS_INFO=\"${BASH_CFG}/info\""

bash_init() {
    if ! cmp -s ${SYS_INFO} ${SYS_INFO}.last; then (
        lib.load config

        config.load ${SYS_INFO}
        config.get system system
        if [[ -z "$system" ]]; then
            system=$(cmd.try "sw_vers -productName" "lsb_release -i -s")
            system=${system,,}
            config.set system "${system}$([[ -n "$WSL_DISTRO_NAME" ]] && echo ':wsl')"
        fi

        config.get bin bin
        if [[ -z "$bin" ]]; then
            config.set bin "${HOME}/.local/bin"
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
}

xdg_init() {
    # XDG Base Directory Specification
    # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
    # https://wiki.archlinux.org/title/XDG_Base_Directory
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
    export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
}

# In ANSI code, for example, '\e[0m' was used for reseting
# '\e' means 'escape string'.
# '[0' is 'function parameters'.
# 'm' is 'function name'
#
# WARN:
# '\[' and '\]' is the exception rule only for PS1 to add a ANSI section
# if there is no esecape section, PS1 would become buggy

__ps1_switch_form() {
    lib.load ansi

    __ps1_git_branch() {
        git branch 2> /dev/null | sed -n "/\* /s/^\* \(.*\)$/\1 /p"
    }

    __wrap() {
        echo '\['$1'\]'
    }

    __ps1_tab() {
        echo -e '\t'
    }

    __ps1_pos() {
        local br dir offset
        br="$(__ps1_git_branch)"
        dir="$(basename $(pwd))"
        offset=15 # '@' + ' '*5 + '$' + TIME(8) + ' '*4
        echo $((${#USER} + ${#HOSTNAME} + ${#br} + ${#dir} + offset))
    }

    local w=$(__wrap "$(ansi 111)")
    local b=$(__wrap "$(ansi 001)")
    local y=$(__wrap "$(ansi 110)")
    local g=$(__wrap "$(ansi 010)")
    local rs=$(__wrap "$_RS")
    local grey=$(__wrap "$(ansi_tc 222222)")
    local purple=$(__wrap "$(ansi_256 115)")
    local orange=$(__wrap "$(ansi_256 510)")

    ps1_short() {
        local var
        var+=${purple}'\t '
        var+=${g}'\u@\h '
        var+=${b}'\W'
        var+=${purple}'${debian_chroot:+(:$debian_chroot)} '
        var+=${orange}'$(__ps1_git_branch)'
        var+=${y}'\$'${rs}' '
        echo "$var"
    }

    ps1_long() {
        local var
        var=${rs}${w}'[\t] ' # Current time
        var+=${purple}'\[\!:\j:$? \]'
        var+=${g}'\[\u@\h \]'
        var+=${b}'\[\w \]'
        var+=${purple}'\[${debian_chroot:+($debian_chroot) }\]'
        var+=${orange}'\[$(__ps1_git_branch)\]\[\r\]'
        var+=${rs}'\[\n\r\] '
        var+=${y}'\$'${rs}' '

        echo "$var"
    }

    if (( __ps1_form == 0 )); then
        PS1="$(ps1_long)"
    else
        # https://unix.stackexchange.com/questions/252228/ps1-prompt-to-show-elapsed-time
        PS1[3]=$SECONDS
        # https://www.gnu.org/software/termutils/manual/termutils-2.0/html_chapter/tput_1.html
        PS1='\[$(tput cuf $(__ps1_pos))\]'
        PS1+=$grey
        PS1+='\['
        PS1+='      <<  '
        PS1+='RET:$?  '
        PS1+='JOB:\j  '
        PS1+='${PS1[!(PS1[1]=!1&(PS1[3]=(PS1[2]=$SECONDS-${PS1[3]})/3600))]#${PS1[3]%%*??}0}$((PS1[3]=(PS1[2]/60%60),${PS1[3]})):${PS1[1]#${PS1[3]%%*??}0}$((PS1[3]=(PS1[2]%60),${PS1[3]})):${PS1[1]#${PS1[3]%%*??}0}$((PS1[3]=(SECONDS),${PS1[3]}))  '
        PS1+='CMD#:\!'
        PS1+='\r'
        PS1+='\]'
        PS1+="$(ps1_short)"
    fi

    __ps1_form=$((__ps1_form ^ 0x1))

    unset __wrap
    lib.unload ansi
}

# __ps1_form=1
# __ps1_switch_form

oneshot bash_init
oneshot xdg_init
