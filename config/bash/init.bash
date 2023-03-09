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
    local var

    var=${white}'[\t] ' # Current time
    var+=${purple}'$? '
    var+=${green}'\u@\h '
    var+=${blue}'\w '
    [[ "$OS" == Linux ]] && var+='${debian_chroot:+($debian_chroot)}'
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
    local var

    var+=${purple}'$? '
    var+=${green}'\u@\h '
    var+=${blue}'\W '
    [[ "$OS" == Linux ]] && var+='${debian_chroot:+($debian_chroot)} '
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

prompt() {
    __ps1_form=0
    __ps1_switch_form
}

source_dirs() {
    local dir file path

    # source target config files
    path="${SHELL_DIR}"
    for dir in $@; do
        for file in $(ls ${path}/${dir}); do
            source ${path}/${dir}/${file}
        done
    done
}

init() {
    # Import customized config
    # export SHELL_DIR
    source ${XDG_CONFIG_HOME}/bash/config

    [[ "$OS" == Darwin ]] && PATH="${HOME}/bin:${PATH}"
}

# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=${HOME}/.config
[[ -z $XDG_DATA_HOME ]] && export XDG_DATA_HOME=${HOME}/.local/share
[[ -z $XDG_CACHE_HOME ]] && export XDG_CACHE_HOME=${HOME}/.cache

OS="$(uname)"

init
source_dirs 'completion' 'alias' 'init'
prompt

unset -f prompt source_dirs init
unset OS
