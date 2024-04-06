# set up XDG_xxx
source $(dirname $BASH_SOURCE)/base/xdg.bash

grep -q -w "${HOME}/bin" <<< "$PATH" || PATH="${HOME}/bin:${PATH}"

eval $(find $(dirname $BASH_SOURCE)/base -type f -exec 'echo' 'source' '{};' ';')

eval $(find ${SHELL_DIR}/{completion,ext} -type f -exec 'echo' 'source' '{};' ';')
