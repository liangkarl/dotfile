#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The STARSHIP_CONFIG variable is a base directory path. It defaults to ~/.enhancd.

STARSHIP_HOME=$(dirname ${BASH_SOURCE[0]})

# init ble.sh.
# source ${dir}/ble.sh/out/ble.sh --noattach --rcfile ${dir}/blerc

# init starship
export STARSHIP_CONFIG=${STARSHIP_HOME}/starship.toml
eval "$(starship init bash)"

# [[ ! ${BLE_VERSION-} ]] || ble-attach
