#!/usr/bin/env bash

[[ -v __YAML_BASH_INCLUDED ]] && return
__YAML_BASH_INCLUDED='none'

sys.stage_start

yaml.load() { ; }
yaml.save() { ; }
yaml.dump() { ; }
yaml.init() { ; }
yaml.reset() { ; }
yaml.get() { ; }
yaml.list_beg() { ; }
yaml.list_end() { ; }
yaml.array_beg() { ; }
yaml.array_end() { ; }
yaml.add_bool() { ; }
yaml.add_num() { ; }
yaml.add_str() { ; }

sys.stage_stop
