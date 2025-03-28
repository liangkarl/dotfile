#!/usr/bin/env bash

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
