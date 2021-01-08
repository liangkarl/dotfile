#!/bin/bash

init_env()
{
	local WHERE="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. >/dev/null 2>&1 && pwd)"
        local DEF_PATH="$1"
        if [ -z "$DEF_PATH" ]; then
                LIB_DIR="$WHERE/lib"
                CONFIG_DIR="$WHERE/config"
                CORE_DIR="$WHERE/core"
        else
                LIB_DIR="$DEF_PATH/lib"
                CONFIG_DIR="$DEF_PATH/config"
                CORE_DIR="$DEF_PATH/core"
        fi
}
