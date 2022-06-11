# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=${HOME}/.config
[[ -z $XDG_DATA_HOME ]] && export XDG_DATA_HOME=${HOME}/.local/share
[[ -z $XDG_CACHE_HOME ]] && export XDG_CACHE_HOME=${HOME}/.cache

OS="$(uname)"
[[ "$OS" == Darwin ]] && PATH="${HOME}/bin:${PATH}"

# Import customized config
source ${XDG_CONFIG_HOME}/bash/config

__custom_prompt() {
    local white='\[\033[01;38m\]'
    local blue='\[\033[01;34m\]'
    local yellow='\[\033[38;5;11m\]'
    local green='\[\033[01;32m\]'
    local purple='\[\033[38;5;63m\]'
    local sed_purple='\\\[\\\033[38;5;63m\\\]'
    local sed_orange='\\\[\\\033[38;5;202m\\\]'
    local reset='\[\033[0m\]'

    PS1=${white}'[\t] ' # Current time
    [[ "$OS" == Linux ]] && PS1+='${debian_chroot:+($debian_chroot)}'
    PS1+=${purple}'$? '
    PS1+=${green}'\u@\h '
    PS1+=${blue}'\w '
    PS1+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/'${sed_purple}'-> '${sed_orange}'\1/")'
    PS1+='\n'${reset}'└─ '
    PS1+=${yellow}'\$'${reset}' '

    export PS1
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

__source_lib_core() {
    source ${SHELL_DIR}/lib/core
}

__custom_prompt
__source_lib_core
source_dirs 'completion' 'alias' 'init'
