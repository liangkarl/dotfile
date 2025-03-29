#!/usr/bin/env bash

# https://github.com/b4b4r07/enhancd
# The STARSHIP_CONFIG variable is a base directory path. It defaults to ~/.enhancd.

__starship_bootstrap() {
    local dir

    dir=$(dirname ${BASH_SOURCE[0]})

    # init ble.sh
    source ${dir}/ble.sh/out/ble.sh --noattach --rcfile ${dir}/blerc

    # init starship
    export STARSHIP_CONFIG=${dir}/starship.toml
    eval "$(starship init bash)"

    [[ ! ${BLE_VERSION-} ]] || ble-attach
}

oneshot __starship_bootstrap
