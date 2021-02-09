export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Used for Android
## Generate compile_commands.json
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1
# Make soong generate a symlink to the compdb file using an env var
# export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT

__customize_ps1() {
    local WHITE='\[\033[01;38m\]'
    local BLUE='\[\033[01;34m\]'
    local LYELLOW='\[\033[38;5;11m\]'
    local GREEN='\[\033[01;32m\]'
    local PURPLE='\[\033[38;5;63m\]'
    local SED_PURPLE='\\\[\\\033[38;5;63m\\\]'
    local SED_ORANGE='\[\\\033[38;5;202m\\\]'
    local RESET='\[$(tput sgr0)\]'

    PS1=${WHITE}'[\t] ' # Current time
    PS1+='${debian_chroot:+($debian_chroot)}'
    PS1+="${PURPLE}\$? "
    PS1+=${GREEN}'\u@\h '
    PS1+=${BLUE}'\w '
    PS1+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/'${SED_PURPLE}'-> '${SED_ORANGE}'\1/")'
    PS1+='\n'${RESET}'└─ '
    PS1+=${LYELLOW}'\$'${RESET}' '

    export PS1
}

__customize_ps1
unset -f __customize_ps1
