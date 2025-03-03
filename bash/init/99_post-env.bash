#!/usr/bin/env bash

msg.dbg "load: $(source.name)"

PATH="$(sys.info my_bin):$PATH"
sys.reload_path
msg.dbg "path reloaded"
