#!/usr/bin/env bash

export BASH_CFG="$(dirname ${BASH_SOURCE[0]})"

# This first call of library should be source
source ${BASH_CFG}/lib/library.bash

# for debug
lib.load devel
lib.load system
# dbg.on

# Order:
# source bash/env/00_pre-env.bash;
# source bash/env/11_xdg.bash;
# source bash/env/12_ps1.bash;
# ...
source.dir "${BASH_CFG}/init"

msg.dbg "path: $PATH"
msg.dbg "completed"
dbg.off

lib.unload devel
lib.unload system
