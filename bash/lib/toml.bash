#!/usr/bin/env bash

[[ -v __TOML_BASH_INCLUDED ]] && return
__TOML_BASH_BEFORE="$(compgen -A function) $(compgen -v)"

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

__TOML_BASH_AFTER="$(compgen -A function) $(compgen -v)"

# time __TOML_BASH_INCLUDED=$(comm -23 <(printf "%s\n" $' '"$__TOML_BASH_AFTER" | sort) <(printf "%s\n" $' '"$__TOML_BASH_BEFORE" | sort))
# time __TOML_BASH_INCLUDED=$(printf "%s\n" $__TOML_BASH_AFTER | grep -Fvx -f <(printf "%s\n" $__TOML_BASH_BEFORE))
__TOML_BASH_INCLUDED=$(awk 'NR==FNR {a[$0]=1; next} !($0 in a)' <(printf "%s\n" $__TOML_BASH_BEFORE) <(printf "%s\n" $__TOML_BASH_AFTER))

unset __TOML_BASH_AFTER __TOML_BASH_BEFORE
