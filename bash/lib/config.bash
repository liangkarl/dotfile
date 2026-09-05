#!/usr/bin/env bash

[[ -v __CONFIG_BASH_INCLUDED ]] && return
__CONFIG_BASH_INCLUDED='none'

sys.stage_start
lib.load devel

__CONFIG_BASH_DBG=$(dbg.mark)
# dbg.on $__CONFIG_BASH_DBG

_config_err() {
    printf 'config: %s\n' "$*" >&2
}

_config_usage() {
    _config_err "$1"
    return 2
}

_config_validate_name() {
    [[ $1 =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || {
        _config_err "invalid variable name: $1"
        return 1
    }
}

_config_require_active() {
    [[ -n ${__CUR_CONFIG:-} && -n ${__CUR_SPACE:-} ]] || {
        _config_err "no configuration loaded"
        return 1
    }
}

_config_variable_name() {
    _config_require_active || return 1
    _config_validate_name "$1" || return 1
    REPLY="__CONFIG_${__CUR_SPACE}_$1"
}

_config_encode_value() {
    local value=$1
    local encoded=""
    local char
    local index

    for ((index = 0; index < ${#value}; index++)); do
        char=${value:index:1}
        case $char in
            \\) encoded+='\\' ;;
            \') encoded+="\\'" ;;
            $'\n') encoded+='\n' ;;
            $'\r') encoded+='\r' ;;
            *) encoded+=$char ;;
        esac
    done

    REPLY="'$encoded'"
}

_config_decode_value() {
    local value=$1
    local decoded=""
    local char
    local next
    local index

    if [[ ${#value} -lt 2 || ${value:0:1} != "'" || ${value:$((${#value} - 1)):1} != "'" ]]; then
        REPLY=$value
        return
    fi

    value=${value:1:$((${#value} - 2))}
    for ((index = 0; index < ${#value}; index++)); do
        char=${value:index:1}
        if [[ $char != \\ ]]; then
            decoded+=$char
            continue
        fi

        ((index++))
        [[ $index -lt ${#value} ]] || {
            _config_err "unterminated escape sequence"
            return 1
        }

        next=${value:index:1}
        case $next in
            \\|\') decoded+=$next ;;
            n) decoded+=$'\n' ;;
            r) decoded+=$'\r' ;;
            *) decoded+="\\$next" ;;
        esac
    done

    REPLY=$decoded
}

_config_mktemp_for() {
    local target_file=$1
    local target_dir
    local target_base

    target_dir=$(dirname "$target_file") || return 1
    target_base=$(basename "$target_file") || return 1
    [[ -d $target_dir ]] || {
        _config_err "directory does not exist: $target_dir"
        return 1
    }

    mktemp "${target_dir}/.${target_base}.tmp.XXXXXX"
}

_config_parse_file() {
    local config_file=$1
    local line
    local name
    local value

    while IFS= read -r line || [[ -n $line ]]; do
        [[ $line =~ ^[[:space:]]*$ || $line =~ ^[[:space:]]*# ]] && continue
        [[ $line == *=* ]] || {
            _config_err "invalid configuration line: $line"
            return 1
        }

        name=${line%%=*}
        value=${line#*=}
        _config_validate_name "$name" || return 1
        _config_decode_value "$value" || return 1
        config.set "$name" "$REPLY" || return 1
    done < "$config_file"
}

# config.set NAME VALUE
config.set() {
    local variable_name

    [[ $# -eq 2 ]] || {
        _config_usage "usage: config.set NAME VALUE"
        return 2
    }

    _config_variable_name "$1" || return 1
    variable_name=$REPLY
    printf -v "$variable_name" '%s' "$2"
}

# config.get OUTPUT_VARIABLE NAME [DEFAULT]
config.get() {
    local variable_name
    local default_value=${3:-}

    [[ $# -ge 2 && $# -le 3 ]] || {
        _config_usage "usage: config.get OUTPUT_VARIABLE NAME [DEFAULT]"
        return 2
    }

    _config_validate_name "$1" || return 1
    _config_variable_name "$2" || return 1
    variable_name=$REPLY

    if [[ -v $variable_name ]]; then
        printf -v "$1" '%s' "${!variable_name}"
    else
        printf -v "$1" '%s' "$default_value"
    fi
}

# config.del NAME
config.del() {
    local variable_name

    [[ $# -eq 1 ]] || {
        _config_usage "usage: config.del NAME"
        return 2
    }

    _config_variable_name "$1" || return 1
    variable_name=$REPLY
    unset "$variable_name"
}

# config.load FILE
config.load() {
    local config_file
    local space

    [[ $# -eq 1 ]] || {
        _config_usage "usage: config.load FILE"
        return 2
    }

    if [[ -n ${__CUR_CONFIG:-} ]]; then
        config.reset
    fi

    config_file=$1
    if [[ ! -e $config_file ]]; then
        : > "$config_file" || {
            _config_err "cannot create configuration file: $config_file"
            return 1
        }
    fi

    [[ -f $config_file ]] || {
        _config_err "not a regular file: $config_file"
        return 1
    }

    space=$(basename "$config_file")
    space=${space^^}
    space=${space//[^[:alnum:]_]/_}
    [[ -n $space ]] || space=CONFIG
    [[ $space =~ ^[0-9] ]] && space="_$space"

    __CUR_CONFIG=$config_file
    __CUR_SPACE=$space

    if ! _config_parse_file "$config_file"; then
        config.reset
        return 1
    fi
}

config.dump() {
    local prefix
    local variable_name
    local name

    _config_require_active || return 1
    prefix="__CONFIG_${__CUR_SPACE}_"

    while IFS= read -r variable_name; do
        name=${variable_name#"$prefix"}
        _config_encode_value "${!variable_name}"
        printf '%s=%s\n' "$name" "$REPLY"
    done < <(compgen -A variable "$prefix" | LC_ALL=C sort)
}

# config.save
config.save() {
    local target_file
    local tmp_file

    _config_require_active || return 1
    target_file=$__CUR_CONFIG
    tmp_file=$(_config_mktemp_for "$target_file") || return 1

    if ! config.dump > "$tmp_file"; then
        rm -f "$tmp_file"
        return 1
    fi

    if ! mv -f "$tmp_file" "$target_file"; then
        rm -f "$tmp_file"
        return 1
    fi

    msg.dbg "save to $target_file"
    config.reset
}

# config.reset
config.reset() {
    local prefix
    local variable_name

    if [[ -n ${__CUR_SPACE:-} ]]; then
        prefix="__CONFIG_${__CUR_SPACE}_"
        while IFS= read -r variable_name; do
            unset "$variable_name"
        done < <(compgen -A variable "$prefix")
    fi

    unset __CUR_CONFIG __CUR_SPACE
}

# config.sort
config.sort() {
    local tmp_file

    _config_require_active || return 1
    tmp_file=$(_config_mktemp_for "$__CUR_CONFIG") || return 1
    if ! LC_ALL=C sort < "$__CUR_CONFIG" > "$tmp_file"; then
        rm -f "$tmp_file"
        return 1
    fi

    if ! mv -f "$tmp_file" "$__CUR_CONFIG"; then
        rm -f "$tmp_file"
        return 1
    fi
}

sys.stage_stop
