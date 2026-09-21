#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The STARSHIP_CONFIG variable is a base directory path. It defaults to ~/.enhancd.

STARSHIP_HOME="${XDG_CONFIG_HOME}/starship"

# init ble.sh.
# source ${XDG_DATA_HOME}/blesh/ble.sh --noattach --rcfile ${XDG_CONFIG_HOME}/starship/blerc
# source ~/.local/share/blesh/ble.sh

# init starship
export STARSHIP_CONFIG=${STARSHIP_HOME}/starship.toml
eval "$(starship init bash)"

# [[ ! ${BLE_VERSION-} ]] || ble-attach
