export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Used for Android
## Generate compile_commands.json
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1
# Make soong generate a symlink to the compdb file using an env var
# export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT

# FIXME: hard code here
export SHELL_DIR=$HOME/shell

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
    PS1+='${debian_chroot:+($debian_chroot)}'
    PS1+=${purple}'$? '
    PS1+=${green}'\u@\h '
    PS1+=${blue}'\w '
    PS1+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/'${sed_purple}'-> '${sed_orange}'\1/")'
    PS1+='\n'${reset}'└─ '
    PS1+=${yellow}'\$'${reset}' '

    export PS1
}

# $FUNCNAME [name]
__knock_helper() {
    local list
    local postfix='_helper.sh'

    list=($(ls ${SHELL_DIR}/tools/*${postfix}))
    if [[ "$list" == '' ]]; then
        return 128
    fi

    local i j
    local name file

    for ((j = 0; j < ${#list[@]}; j++)); do
        file=$(basename ${list[$j]})
        name=${file//${postfix}}
        if [[ "$1" == $name ]]; then
            echo "call helper: $name"
            . ${list[$j]}
            return 0
        fi
    done

    echo "unsupport helper: $name"
    return 128
}

__knock_helper_compl() {
    local list postfix
    postfix='_helper.sh'
    list="$(cd ${SHELL_DIR}/tools/ 2>&- && ls *${postfix})"
    list=${list//$postfix}

    COMPREPLY=($(compgen -W "$list" "${COMP_WORDS[1]}"))
}

__import_completion() {
    local completion_dir="$HOME/.config/bash/completion"
    local file

    for file in $completion_dir/*; do
        source $file
    done
}

__import_alias() {
    local alias_dir="$HOME/.config/bash/alias"
    local file

    for file in $alias_dir/*; do
        source $file
    done
}

__custom_prompt
__import_completion
__import_alias
