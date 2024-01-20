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
    local white='\[\e[01;38m\]'
    local blue='\[\e[01;34m\]'
    local yellow='\[\e[38;5;11m\]'
    local green='\[\e[01;32m\]'
    local purple='\[\e[38;5;63m\]'
    local orange='\[\e[38;5;202m\]'
    local sed_purple='\\\[\\\e[38;5;63m\\\]'
    local sed_orange='\\\[\\\e[38;5;202m\\\]'
    local reset='\[\e[0m\]'
    local var

    ps1_short() {
        var+=${purple}'$? '
        var+=${green}'\u@\h '
        var+=${blue}'\W'
        var+=${purple}'${debian_chroot:+(:$debian_chroot)}'
        var+='$(git branch 2>&- | sed -n "/\* /s/^\* \(.*\)$/'${sed_purple}':'${sed_orange}'\1/p")'
        var+=${yellow}' \$'${reset}' '
        echo "$var"
    }

    ps1_long() {
        var=${white}'[\t] ' # Current time
        var+=${purple}'$? '
        var+=${green}'\u@\h '
        var+=${blue}'\w '
        var+=${purple}'${debian_chroot:+($debian_chroot) }'
        var+='$(git branch 2>&- | sed -n "/\* /s/^\* \(.*\)$/'${sed_purple}'-> '${sed_orange}'\1/p") '
        var+=${reset}'\n└─ '
        var+=${yellow}'\$'${reset}' '

        echo "$var"
    }


    if (( __ps1_form == 0 )); then
        PS1="$(ps1_long)"
    else
        # https://unix.stackexchange.com/questions/252229/ps1-prompt-to-show-elapsed-time
        PS1[3]=$SECONDS
        PS1='[${PS1[!(PS1[1]=!1&(PS1[3]=(PS1[2]=$SECONDS-${PS1[3]})/3600))]#${PS1[3]%%*??}0}$((PS1[3]=(PS1[2]/60%60),${PS1[3]})):${PS1[1]#${PS1[3]%%*??}0}$((PS1[3]=(PS1[2]%60),${PS1[3]})):${PS1[1]#${PS1[3]%%*??}0}$((PS1[3]=(SECONDS),${PS1[3]}))] '
        PS1+="$(ps1_short)"
    fi

    __ps1_form=$((__ps1_form ^ 0x1))
}

__ps1_form=1
__ps1_switch_form
