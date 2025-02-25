#!/usr/bin/env bash

# Order:
# source bash/env/00_pre-env.bash;
# source bash/env/11_xdg.bash;
# source bash/env/12_ps1.bash;
# source bash/env/21_fuzzy-finder.bash;
# source bash/env/22_android.bash;
# source bash/env/30_misc.bash;
# source bash/env/99_post-env.bash;
eval $(find ${SHELL_DIR}/init -type f -exec 'echo' 'source' '{};' ';' | sort)

grep -q -w "${HOME}/.local/bin" <<< "$PATH" || PATH="${HOME}/.local/bin:${PATH}"

path.brew
path.nvm
