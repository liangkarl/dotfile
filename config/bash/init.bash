#
# NOTE:
# This script should be sourced at the tail of .bashrc or .bash_profile
#

#
# In ANSI code, for example, '\e[0m' was used for reseting
# '\e' means 'escape string'.
# '[0' is 'function parameters'.
# 'm' is 'function name'
#
# WARN:
# '\[' and '\]' is the exception rule only for PS1 to add a ANSI section
# if there is no esecape section, PS1 would become buggy
#

__ps1_long_form() {
    local white='\[\e[01;38m\]'
    local blue='\[\e[01;34m\]'
    local yellow='\[\e[38;5;11m\]'
    local green='\[\e[01;32m\]'
    local purple='\[\e[38;5;63m\]'
    local orange='\[\e[38;5;202m\]'
    local sed_purple='\\\[\\\e[38;5;63m\\\]'
    local sed_orange='\\\[\\\e[38;5;202m\\\]'
    local reset='\[\e[0m\]'
    local kernel=$(uname -s)
    local var

    var=${white}'[\t] ' # Current time
    var+=${purple}'$? '
    var+=${green}'\u@\h '
    var+=${blue}'\w '
    [[ "$kernel" == Linux ]] && var+='${debian_chroot:+($debian_chroot)}'
    var+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/'${sed_purple}'-> '${sed_orange}'\1/") '
    var+=${reset}'\n└─ '
    var+=${yellow}'\$'${reset}' '

    echo "$var"
}

__ps1_short_form() {
    local white='\[\e[01;38m\]'
    local blue='\[\e[01;34m\]'
    local yellow='\[\e[38;5;11m\]'
    local green='\[\e[01;32m\]'
    local purple='\[\e[38;5;63m\]'
    local orange='\[\e[38;5;202m\]'
    local sed_purple='\\\[\\\e[38;5;63m\\\]'
    local sed_orange='\\\[\\\e[38;5;202m\\\]'
    local reset='\[\e[0m\]'
    local kernel=$(uname -s)
    local var

    var+=${purple}'$? '
    var+=${green}'\u@\h '
    var+=${blue}'\W '
    [[ "$kernel" == Linux ]] && var+='${debian_chroot:+($debian_chroot)} '
    var+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/'${sed_purple}'-> '${sed_orange}'\1/") '
    var+=${yellow}'\$'${reset}' '

    echo "$var"
}

__ps1_switch_form() {
    if (( __ps1_form == 0 )); then
        PS1="$(__ps1_long_form)"
    else
        PS1="$(__ps1_short_form)"
    fi

    __ps1_form=$((__ps1_form ^ 0x1))
}

__ps1_prompt() {
    __ps1_form=0
    __ps1_switch_form
}

__xdg_config() {
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

__xdg_config

# Import customized config
# export SHELL_DIR
source ${XDG_CONFIG_HOME}/bash/config
grep -q -w "${HOME}/bin" <<< "$PATH" || PATH="${HOME}/bin:${PATH}"

eval source $(find ${SHELL_DIR}/{completion,alias,init} -type f \
        | xargs \
        | sed 's/ /; source /g')

__ps1_prompt
