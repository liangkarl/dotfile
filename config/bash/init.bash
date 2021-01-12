export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Used for Android
## Generate compile_commands.json
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1
# Make soong generate a symlink to the compdb file using an env var
# export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT

PS1='\[\033[01;38m\][\t] ' # Current time
PS1+='${debian_chroot:+($debian_chroot)}'
PS1+='\[\033[01;32m\]\u@\h'
PS1+=' \[\033[01;34m\]\w'
PS1+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/ \\\[\\\033[38;5;63m\\\](\\\[\\\033[38;5;202m\\\]\1\\\[\\\033[38;5;63m\\\])/")'
PS1+='\n\[$(tput sgr0)\]└─'
PS1+=' \[\033[38;5;11m\]\$\[$(tput sgr0)\] '
export PS1
