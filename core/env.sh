#!/bin/bash

WHERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

init_env()
{
        local -r ASSIGNED_PATH=$1
        if [ -z "$1" ]; then
                LIB_DIR="$WHERE/lib"
                CONFIG_DIR="$WHERE/config"
                CORE_DIR="$WHERE/core"
        else
                LIB_DIR="$ASSIGNED_PATH/lib"
                CONFIG_DIR="$ASSIGNED_PATH/config"
                CORE_DIR="$ASSIGNED_PATH/core"
        fi
}
