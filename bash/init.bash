#!/usr/bin/env bash

# Order:
# source bash/env/00_pre-env.bash;
# source bash/env/11_xdg.bash;
# source bash/env/12_ps1.bash;
# ...
eval $(find ${SHELL_DIR}/init -type f -exec 'echo' 'source' '{};' ';' | sort)
