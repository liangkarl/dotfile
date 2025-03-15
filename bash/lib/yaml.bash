#!/usr/bin/env bash

[[ -v __YAML_BASH_INCLUDED ]] && return
__YAML_BASH_BEFORE="$(compgen -A function) $(compgen -v)"

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

__YAML_BASH_AFTER="$(compgen -A function) $(compgen -v)"

# time __YAML_BASH_INCLUDED=$(comm -23 <(printf "%s\n" $' '"$__YAML_BASH_AFTER" | sort) <(printf "%s\n" $' '"$__YAML_BASH_BEFORE" | sort))
# time __YAML_BASH_INCLUDED=$(printf "%s\n" $__YAML_BASH_AFTER | grep -Fvx -f <(printf "%s\n" $__YAML_BASH_BEFORE))
__YAML_BASH_INCLUDED=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__YAML_BASH_BEFORE) <(printf "%s\n" $__YAML_BASH_AFTER))

unset __YAML_BASH_AFTER __YAML_BASH_BEFORE
