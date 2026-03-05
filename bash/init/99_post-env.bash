#!/usr/bin/env bash

source ${XDG_CONFIG_HOME}/bash/prompt-completion.bash

PATH="$(sys.info bin):$PATH"
dbg.cmd "sys.reload_path"
