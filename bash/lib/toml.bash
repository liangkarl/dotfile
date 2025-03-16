#!/usr/bin/env bash

[[ -v __TOML_BASH_INCLUDED ]] && return
__TOML_BASH_INCLUDED='none'

sys.stage_start

toml.load() { ; }
toml.save() { ; }
toml.dump() { ; }
toml.init() { ; }
toml.reset() { ; }
toml.get() { ; }
toml.list_beg() { ; }
toml.list_end() { ; }
toml.array_beg() { ; }
toml.array_end() { ; }
toml.add_bool() { ; }
toml.add_num() { ; }
toml.add_str() { ; }

sys.stage_stop
