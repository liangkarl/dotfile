source $(dirname $BASH_SOURCE)/base/{ps1,xdg}.bash

# Import customized config
# export SHELL_DIR
source ${XDG_CONFIG_HOME}/bash/config
grep -q -w "${HOME}/bin" <<< "$PATH" || PATH="${HOME}/bin:${PATH}"

eval $(find ${SHELL_DIR}/{completion,ext} -type f -exec 'echo' 'source' '{};' ';')
