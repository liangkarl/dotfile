#!/usr/bin/env bash
# yaml_builder_lib.sh
# shellcheck shell=bash

if [[ -z ${BASH_VERSION:-} ]]; then
    printf 'yaml_builder_lib.sh: bash is required\n' >&2
    return 1 2>/dev/null || exit 1
fi

: "${YAML_LIB_YQ:=yq}"
: "${YAML_LIB_JQ:=jq}"

YAML_LIB_SOURCE_TYPE=""
YAML_LIB_SOURCE_VALUE=""
YAML_LIB_BUILD_FILE=""
YAML_LIB_BUILD_STATE=""
YAML_LIB_BUILD_PATHS=()

_yaml_err() {
    printf 'yaml_lib: %s\n' "$*" >&2
}

_yaml_usage() {
    _yaml_err "$1"
    return 2
}

_yaml_cleanup_builder() {
    if [[ -n ${YAML_LIB_BUILD_STATE:-} && -f ${YAML_LIB_BUILD_STATE:-} ]]; then
        rm -f -- "$YAML_LIB_BUILD_STATE"
    fi

    YAML_LIB_BUILD_FILE=""
    YAML_LIB_BUILD_STATE=""
    YAML_LIB_BUILD_PATHS=()
}

_yaml_mktemp_for() {
    local target_file=$1
    local target_dir
    local target_base

    target_dir=$(dirname -- "$target_file") || return 1
    target_base=$(basename -- "$target_file") || return 1

    [[ -d $target_dir ]] || {
        _yaml_err "directory does not exist: $target_dir"
        return 1
    }

    mktemp "${target_dir}/.${target_base}.tmp.XXXXXX"
}

_yaml_mktemp_state() {
    mktemp "${TMPDIR:-/tmp}/yaml_lib.state.XXXXXX"
}

_yaml_move_into_place() {
    local src_file=$1
    local dst_file=$2
    mv -f -- "$src_file" "$dst_file"
}

_yaml_emit_state_as_yaml() {
	[[ $# -eq 1 ]] || {
		_yaml_err "usage: _yaml_emit_state_as_yaml STATE_FILE"
		return 2
	}

	yaml_require_yq || return $?
	yq eval --no-colors -p=json -oy . "$1"
}

_yaml_builder_path_count() {
    printf '%s' "${#YAML_LIB_BUILD_PATHS[@]}"
}

_yaml_builder_current_path_json() {
    local count
    count=$(_yaml_builder_path_count)

    [[ $count -gt 0 ]] || {
        _yaml_err "no active YAML builder session, call yaml_begin_file or yaml_begin_text first"
        return 1
    }

    printf '%s' "${YAML_LIB_BUILD_PATHS[$((count - 1))]}"
}

_yaml_builder_push_path_json() {
    YAML_LIB_BUILD_PATHS[${#YAML_LIB_BUILD_PATHS[@]}]=$1
}

_yaml_builder_pop_path_json() {
    local count
    count=$(_yaml_builder_path_count)

    [[ $count -gt 1 ]] || {
        _yaml_err "already at root container"
        return 1
    }

    unset 'YAML_LIB_BUILD_PATHS[$((count - 1))]'
}

_yaml_path_append_key() {
    local path_json=$1
    local key=$2

    "$YAML_LIB_JQ" -cn --argjson path "$path_json" --arg key "$key" '$path + [$key]'
}

_yaml_path_append_index() {
    local path_json=$1
    local index=$2

    "$YAML_LIB_JQ" -cn --argjson path "$path_json" --argjson index "$index" '$path + [$index]'
}

_yaml_builder_apply() {
    local jq_filter=$1
    shift

    local tmp_file

    [[ -n ${YAML_LIB_BUILD_STATE:-} && -f ${YAML_LIB_BUILD_STATE:-} ]] || {
        _yaml_err "no active YAML builder session, call yaml_begin_file or yaml_begin_text first"
        return 1
    }

    tmp_file=$(_yaml_mktemp_for "$YAML_LIB_BUILD_STATE") || return 1

    if ! "$YAML_LIB_JQ" "$@" "$jq_filter" "$YAML_LIB_BUILD_STATE" > "$tmp_file"; then
        rm -f -- "$tmp_file"
        return 1
    fi

    _yaml_move_into_place "$tmp_file" "$YAML_LIB_BUILD_STATE"
}

_yaml_builder_current_type() {
    local path_json

    path_json=$(_yaml_builder_current_path_json) || return 1
    "$YAML_LIB_JQ" -r --argjson path "$path_json" 'getpath($path) | type' "$YAML_LIB_BUILD_STATE"
}

_yaml_builder_require_type() {
    local expected_type=$1
    local actual_type

    actual_type=$(_yaml_builder_current_type) || return 1
    [[ $actual_type == "$expected_type" ]] || {
        _yaml_err "current container type is $actual_type, expected $expected_type"
        return 1
    }
}

_yaml_builder_current_length() {
    local path_json

    path_json=$(_yaml_builder_current_path_json) || return 1
    "$YAML_LIB_JQ" -r --argjson path "$path_json" 'getpath($path) | length' "$YAML_LIB_BUILD_STATE"
}

_yaml_builder_require_single_document() {
    local state_file=$1

    "$YAML_LIB_JQ" -e -s 'length == 1' "$state_file" >/dev/null || {
        _yaml_err "YAML builder supports exactly one document"
        return 1
    }
}

_yaml_builder_start_with_text() {
    local yaml_text=$1
    local state_file

    yaml_validate "$yaml_text" || return 1
    state_file=$(_yaml_mktemp_state) || return 1

    if ! printf '%s' "$yaml_text" | "$YAML_LIB_YQ" eval --no-colors -o=json -I=0 '.' - > "$state_file"; then
        rm -f -- "$state_file"
        return 1
    fi

    if [[ ! -s $state_file ]]; then
        printf '{}\n' > "$state_file"
    fi

    if ! _yaml_builder_require_single_document "$state_file"; then
        rm -f -- "$state_file"
        return 1
    fi

    _yaml_cleanup_builder
    YAML_LIB_BUILD_STATE=$state_file
    YAML_LIB_BUILD_PATHS=('[]')
}

_yaml_validate_int() {
    [[ $1 =~ ^-?[0-9]+$ ]] || {
        _yaml_err "invalid integer: $1"
        return 1
    }
}

_yaml_validate_float() {
    [[ $1 =~ ^-?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$ ]] || {
        _yaml_err "invalid float: $1"
        return 1
    }
}

_yaml_validate_bool() {
    [[ $1 == "true" || $1 == "false" ]] || {
        _yaml_err "boolean value must be true or false"
        return 1
    }
}

# API: yaml_require_yq
# Usage: yaml_require_yq
# Description:
#   Check whether yq is available in PATH.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   127 if yq is not found.
yaml_require_yq() {
    command -v "$YAML_LIB_YQ" >/dev/null 2>&1 || {
        _yaml_err "yq is required but was not found in PATH"
        return 127
    }
}

# API: yaml_require_jq
# Usage: yaml_require_jq
# Description:
#   Check whether jq is available in PATH.
#   jq is used internally by the builder implementation.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   127 if jq is not found.
yaml_require_jq() {
    command -v "$YAML_LIB_JQ" >/dev/null 2>&1 || {
        _yaml_err "jq is required but was not found in PATH"
        return 127
    }
}

# API: yaml_validate
# Usage: yaml_validate YAML_TEXT
# Description:
#   Validate whether a raw YAML string is syntactically valid YAML.
# Output:
#   No stdout output.
# Return:
#   0 if YAML_TEXT is valid YAML.
#   Non-zero otherwise.
yaml_validate() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_validate YAML_TEXT"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors '.' - >/dev/null
}

# API: yaml_validate_file
# Usage: yaml_validate_file FILE
# Description:
#   Validate whether a file contains syntactically valid YAML.
# Output:
#   No stdout output.
# Return:
#   0 if FILE contains valid YAML.
#   Non-zero otherwise.
yaml_validate_file() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_validate_file FILE"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors '.' "$1" >/dev/null
}

# API: yaml_validate_stdin
# Usage: yaml_validate_stdin
# Description:
#   Validate whether stdin contains syntactically valid YAML.
# Output:
#   No stdout output.
# Return:
#   0 if stdin contains valid YAML.
#   Non-zero otherwise.
yaml_validate_stdin() {
    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_validate_stdin"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors '.' - >/dev/null
}

# API: yaml_file
# Usage: yaml_file FILE
# Description:
#   Set the current YAML source to a file for read APIs.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if FILE does not exist or is not valid YAML.
yaml_file() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_file FILE"
        return 2
    }

    [[ -f $1 ]] || {
        _yaml_err "file not found: $1"
        return 1
    }

    yaml_validate_file "$1" || {
        _yaml_err "invalid YAML file: $1"
        return 1
    }

    YAML_LIB_SOURCE_TYPE="file"
    YAML_LIB_SOURCE_VALUE=$1
}

# API: yaml_text
# Usage: yaml_text YAML_TEXT
# Description:
#   Set the current YAML source to raw YAML text for read APIs.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if YAML_TEXT is not valid YAML.
yaml_text() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_text YAML_TEXT"
        return 2
    }

    yaml_validate "$1" || {
        _yaml_err "invalid YAML text"
        return 1
    }

    YAML_LIB_SOURCE_TYPE="text"
    YAML_LIB_SOURCE_VALUE=$1
}

# API: yaml_clear
# Usage: yaml_clear
# Description:
#   Clear the current read source and any active builder session.
# Output:
#   No stdout output.
# Return:
#   0 always.
yaml_clear() {
    YAML_LIB_SOURCE_TYPE=""
    YAML_LIB_SOURCE_VALUE=""
    _yaml_cleanup_builder
}

# API: yaml_info
# Usage: yaml_info
# Description:
#   Print current read source and builder target information.
# Output:
#   Prints lines describing the current source and builder state.
# Return:
#   0 on success.
yaml_info() {
    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_info"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            printf 'source_type=file\n'
            printf 'source_value=%s\n' "$YAML_LIB_SOURCE_VALUE"
            ;;
        text)
            printf 'source_type=text\n'
            printf 'source_value=%s\n' "$YAML_LIB_SOURCE_VALUE"
            ;;
        *)
            printf 'source_type=none\n'
            ;;
    esac

    if [[ -n ${YAML_LIB_BUILD_STATE:-} ]]; then
        printf 'builder=active\n'
        printf 'builder_file=%s\n' "$YAML_LIB_BUILD_FILE"
    else
        printf 'builder=none\n'
    fi
}

# API: yaml_query
# Usage: yaml_query YQ_FILTER
# Description:
#   Run a yq expression against the current YAML source and print YAML output.
# Output:
#   Prints YAML.
# Return:
#   0 on success.
#   Non-zero on missing source or yq failure.
yaml_query() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_query YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_query_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_query_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_get
# Usage: yaml_get YQ_FILTER
# Description:
#   Read a scalar value from the current YAML source.
#   Missing or null values are treated as errors.
# Output:
#   Prints the scalar value in text form.
# Return:
#   0 on success.
#   Non-zero on missing source, missing value, null value, or yq failure.
yaml_get() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_get YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_get_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_get_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_getd
# Usage: yaml_getd YQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from the current YAML source.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on missing source or yq failure.
yaml_getd() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_getd YQ_FILTER DEFAULT_TEXT"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_getd_from_file "$YAML_LIB_SOURCE_VALUE" "$1" "$2"
            ;;
        text)
            yaml_getd_from_text "$YAML_LIB_SOURCE_VALUE" "$1" "$2"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_has
# Usage: yaml_has YQ_FILTER
# Description:
#   Test whether the yq result from the current source is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
yaml_has() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_has YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_has_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_has_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_each
# Usage: yaml_each YQ_FILTER
# Description:
#   Iterate over a sequence from the current source.
#   Each element is printed as one compact JSON line.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on missing source or yq failure.
yaml_each() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_each YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_each_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_each_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_len
# Usage: yaml_len YQ_FILTER
# Description:
#   Print the length of the yq result from the current source.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on missing source or yq failure.
yaml_len() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_len YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_len_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_len_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_keys
# Usage: yaml_keys YQ_FILTER
# Description:
#   Print the keys of a map from the current source, one key per line.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on missing source or yq failure.
yaml_keys() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_keys YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_keys_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_keys_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_type
# Usage: yaml_type YQ_FILTER
# Description:
#   Print the tag of the yq result from the current source.
# Output:
#   Prints the YAML tag as text, such as !!str or !!map.
# Return:
#   0 on success.
#   Non-zero on missing source or yq failure.
yaml_type() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_type YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_type_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_type_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_true
# Usage: yaml_true YQ_FILTER
# Description:
#   Test whether the yq result from the current source is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
yaml_true() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_true YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_true_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_true_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_false
# Usage: yaml_false YQ_FILTER
# Description:
#   Test whether the yq result from the current source is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
yaml_false() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_false YQ_FILTER"
        return 2
    }

    case $YAML_LIB_SOURCE_TYPE in
        file)
            yaml_false_from_file "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            yaml_false_from_text "$YAML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _yaml_err "no current YAML source, call yaml_file or yaml_text first"
            return 1
            ;;
    esac
}

# API: yaml_query_from_file
# Usage: yaml_query_from_file FILE YQ_FILTER
# Description:
#   Run a yq expression against a specific YAML file and print YAML output.
# Output:
#   Prints YAML.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_query_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_query_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors "$2" "$1"
}

# API: yaml_query_from_text
# Usage: yaml_query_from_text YAML_TEXT YQ_FILTER
# Description:
#   Run a yq expression against raw YAML text and print YAML output.
# Output:
#   Prints YAML.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_query_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_query_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors "$2" -
}

# API: yaml_query_from_stdin
# Usage: yaml_query_from_stdin YQ_FILTER
# Description:
#   Run a yq expression against YAML on stdin and print YAML output.
# Output:
#   Prints YAML.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_query_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_query_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors "$1" -
}

# API: yaml_get_from_file
# Usage: yaml_get_from_file FILE YQ_FILTER
# Description:
#   Read a scalar value from a specific YAML file.
# Output:
#   Prints the scalar value in text form.
# Return:
#   0 on success.
#   Non-zero on missing value, null value, or yq failure.
yaml_get_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_get_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null))" "$1"
}

# API: yaml_get_from_text
# Usage: yaml_get_from_text YAML_TEXT YQ_FILTER
# Description:
#   Read a scalar value from raw YAML text.
# Output:
#   Prints the scalar value in text form.
# Return:
#   0 on success.
#   Non-zero on missing value, null value, or yq failure.
yaml_get_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_get_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null))" -
}

# API: yaml_get_from_stdin
# Usage: yaml_get_from_stdin YQ_FILTER
# Description:
#   Read a scalar value from YAML on stdin.
# Output:
#   Prints the scalar value in text form.
# Return:
#   0 on success.
#   Non-zero on missing value, null value, or yq failure.
yaml_get_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_get_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) | select(. != null))" -
}

# API: yaml_getd_from_file
# Usage: yaml_getd_from_file FILE YQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from a specific YAML file.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_getd_from_file() {
    local value_tag

    [[ $# -eq 3 ]] || {
        _yaml_usage "usage: yaml_getd_from_file FILE YQ_FILTER DEFAULT_TEXT"
        return 2
    }

    yaml_require_yq || return $?
    value_tag=$("$YAML_LIB_YQ" eval --no-colors "(($2) | tag)" "$1") || return 1
    if [[ $value_tag == "!!null" ]]; then
        printf '%s\n' "$3"
    else
        "$YAML_LIB_YQ" eval --no-colors "$2" "$1"
    fi
}

# API: yaml_getd_from_text
# Usage: yaml_getd_from_text YAML_TEXT YQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from raw YAML text.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_getd_from_text() {
    local value_tag

    [[ $# -eq 3 ]] || {
        _yaml_usage "usage: yaml_getd_from_text YAML_TEXT YQ_FILTER DEFAULT_TEXT"
        return 2
    }

    yaml_require_yq || return $?
    value_tag=$(printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors "(($2) | tag)" -) || return 1
    if [[ $value_tag == "!!null" ]]; then
        printf '%s\n' "$3"
    else
        printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors "$2" -
    fi
}

# API: yaml_getd_from_stdin
# Usage: yaml_getd_from_stdin YQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from YAML on stdin.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_getd_from_stdin() {
    local yaml_text

    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_getd_from_stdin YQ_FILTER DEFAULT_TEXT"
        return 2
    }

    yaml_text=$(cat)
    yaml_getd_from_text "$yaml_text" "$1" "$2"
}

# API: yaml_has_from_file
# Usage: yaml_has_from_file FILE YQ_FILTER
# Description:
#   Test whether the yq result from a specific YAML file is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
yaml_has_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_has_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) != null)" "$1" >/dev/null 2>&1
}

# API: yaml_has_from_text
# Usage: yaml_has_from_text YAML_TEXT YQ_FILTER
# Description:
#   Test whether the yq result from raw YAML text is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
yaml_has_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_has_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) != null)" - >/dev/null 2>&1
}

# API: yaml_has_from_stdin
# Usage: yaml_has_from_stdin YQ_FILTER
# Description:
#   Test whether the yq result from YAML on stdin is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
yaml_has_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_has_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) != null)" - >/dev/null 2>&1
}

# API: yaml_each_from_file
# Usage: yaml_each_from_file FILE YQ_FILTER
# Description:
#   Iterate over a sequence from a specific YAML file.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_each_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_each_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors -o=json -I=0 "(($2)[])" "$1"
}

# API: yaml_each_from_text
# Usage: yaml_each_from_text YAML_TEXT YQ_FILTER
# Description:
#   Iterate over a sequence from raw YAML text.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_each_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_each_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors -o=json -I=0 "(($2)[])" -
}

# API: yaml_each_from_stdin
# Usage: yaml_each_from_stdin YQ_FILTER
# Description:
#   Iterate over a sequence from YAML on stdin.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_each_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_each_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors -o=json -I=0 "(($1)[])" -
}

# API: yaml_len_from_file
# Usage: yaml_len_from_file FILE YQ_FILTER
# Description:
#   Print the length of the yq result from a specific YAML file.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_len_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_len_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null) | length)" "$1"
}

# API: yaml_len_from_text
# Usage: yaml_len_from_text YAML_TEXT YQ_FILTER
# Description:
#   Print the length of the yq result from raw YAML text.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_len_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_len_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null) | length)" -
}

# API: yaml_len_from_stdin
# Usage: yaml_len_from_stdin YQ_FILTER
# Description:
#   Print the length of the yq result from YAML on stdin.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_len_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_len_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) | select(. != null) | length)" -
}

# API: yaml_keys_from_file
# Usage: yaml_keys_from_file FILE YQ_FILTER
# Description:
#   Print the keys of a map from a specific YAML file.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_keys_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_keys_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null) | keys | .[])" "$1"
}

# API: yaml_keys_from_text
# Usage: yaml_keys_from_text YAML_TEXT YQ_FILTER
# Description:
#   Print the keys of a map from raw YAML text.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_keys_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_keys_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null) | keys | .[])" -
}

# API: yaml_keys_from_stdin
# Usage: yaml_keys_from_stdin YQ_FILTER
# Description:
#   Print the keys of a map from YAML on stdin.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_keys_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_keys_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) | select(. != null) | keys | .[])" -
}

# API: yaml_type_from_file
# Usage: yaml_type_from_file FILE YQ_FILTER
# Description:
#   Print the YAML tag of the result from a specific YAML file.
# Output:
#   Prints the tag as text.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_type_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_type_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null) | tag)" "$1"
}

# API: yaml_type_from_text
# Usage: yaml_type_from_text YAML_TEXT YQ_FILTER
# Description:
#   Print the YAML tag of the result from raw YAML text.
# Output:
#   Prints the tag as text.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_type_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_type_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) | select(. != null) | tag)" -
}

# API: yaml_type_from_stdin
# Usage: yaml_type_from_stdin YQ_FILTER
# Description:
#   Print the YAML tag of the result from YAML on stdin.
# Output:
#   Prints the tag as text.
# Return:
#   0 on success.
#   Non-zero on yq failure.
yaml_type_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_type_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) | select(. != null) | tag)" -
}

# API: yaml_true_from_file
# Usage: yaml_true_from_file FILE YQ_FILTER
# Description:
#   Test whether the yq result from a specific YAML file is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
yaml_true_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_true_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) == true)" "$1" >/dev/null
}

# API: yaml_true_from_text
# Usage: yaml_true_from_text YAML_TEXT YQ_FILTER
# Description:
#   Test whether the yq result from raw YAML text is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
yaml_true_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_true_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) == true)" - >/dev/null
}

# API: yaml_true_from_stdin
# Usage: yaml_true_from_stdin YQ_FILTER
# Description:
#   Test whether the yq result from YAML on stdin is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
yaml_true_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_true_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) == true)" - >/dev/null
}

# API: yaml_false_from_file
# Usage: yaml_false_from_file FILE YQ_FILTER
# Description:
#   Test whether the yq result from a specific YAML file is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
yaml_false_from_file() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_false_from_file FILE YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) == false)" "$1" >/dev/null
}

# API: yaml_false_from_text
# Usage: yaml_false_from_text YAML_TEXT YQ_FILTER
# Description:
#   Test whether the yq result from raw YAML text is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
yaml_false_from_text() {
    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_false_from_text YAML_TEXT YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    printf '%s' "$1" | "$YAML_LIB_YQ" eval --no-colors --exit-status "(($2) == false)" - >/dev/null
}

# API: yaml_false_from_stdin
# Usage: yaml_false_from_stdin YQ_FILTER
# Description:
#   Test whether the yq result from YAML on stdin is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
yaml_false_from_stdin() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_false_from_stdin YQ_FILTER"
        return 2
    }

    yaml_require_yq || return $?
    "$YAML_LIB_YQ" eval --no-colors --exit-status "(($1) == false)" - >/dev/null
}

# API: yaml_begin_file
# Usage: yaml_begin_file FILE
# Description:
#   Start a builder session backed by FILE.
#   If FILE exists and is valid YAML, it is loaded and converted into a plain JSON-like tree.
#   If FILE does not exist or is empty, a new empty object is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on parse failure or builder setup failure.
yaml_begin_file() {
    local target_file
    local state_file

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_begin_file FILE"
        return 2
    }

    target_file=$1

    yaml_require_yq || return $?
    yaml_require_jq || return $?

    state_file=$(_yaml_mktemp_state) || return 1

    if [[ -f $target_file && -s $target_file ]]; then
        if ! "$YAML_LIB_YQ" eval --no-colors -o=json -I=0 '.' "$target_file" > "$state_file"; then
            rm -f -- "$state_file"
            return 1
        fi
    else
        printf '{}\n' > "$state_file"
    fi

    if ! _yaml_builder_require_single_document "$state_file"; then
        rm -f -- "$state_file"
        return 1
    fi

    _yaml_cleanup_builder
    YAML_LIB_BUILD_FILE=$target_file
    YAML_LIB_BUILD_STATE=$state_file
    YAML_LIB_BUILD_PATHS=('[]')

    YAML_LIB_SOURCE_TYPE="file"
    YAML_LIB_SOURCE_VALUE=$target_file
}

# API: yaml_begin_text
# Usage: yaml_begin_text YAML_TEXT
# Description:
#   Start a builder session from raw YAML text.
#   This session has no output file until yaml_save FILE is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on parse failure or builder setup failure.
yaml_begin_text() {
    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_begin_text YAML_TEXT"
        return 2
    }

    yaml_require_yq || return $?
    yaml_require_jq || return $?
    _yaml_builder_start_with_text "$1" || return 1

    YAML_LIB_SOURCE_TYPE="text"
    YAML_LIB_SOURCE_VALUE=$1
}

# API: yaml_reset
# Usage: yaml_reset [object|array]
# Description:
#   Reset the active builder session to an empty root container.
#   The default root type is object.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid usage or missing builder session.
yaml_reset() {
    local root_type=${1:-object}

    [[ $# -le 1 ]] || {
        _yaml_usage "usage: yaml_reset [object|array]"
        return 2
    }

    yaml_require_jq || return $?

    [[ -n ${YAML_LIB_BUILD_STATE:-} ]] || {
        _yaml_err "no active YAML builder session"
        return 1
    }

    case $root_type in
        object)
            printf '{}\n' > "$YAML_LIB_BUILD_STATE"
            ;;
        array)
            printf '[]\n' > "$YAML_LIB_BUILD_STATE"
            ;;
        *)
            _yaml_err "root type must be object or array"
            return 1
            ;;
    esac

    YAML_LIB_BUILD_PATHS=('[]')
}

# API: yaml_print
# Usage: yaml_print
# Description:
#   Print the current builder document as YAML.
# Output:
#   Prints the current builder YAML document.
# Return:
#   0 on success.
#   Non-zero on missing builder session.
yaml_print() {
    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_print"
        return 2
    }

    [[ -n ${YAML_LIB_BUILD_STATE:-} && -f ${YAML_LIB_BUILD_STATE:-} ]] || {
        _yaml_err "no active YAML builder session"
        return 1
    }

	_yaml_emit_state_as_yaml "$YAML_LIB_BUILD_STATE"
}

# API: yaml_save
# Usage: yaml_save [FILE]
# Description:
#   Save the current builder document to FILE.
#   If FILE is omitted, the file passed to yaml_begin_file is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on missing builder session or save failure.
yaml_save() {
    local target_file=${1:-$YAML_LIB_BUILD_FILE}
    local tmp_file

    [[ $# -le 1 ]] || {
        _yaml_usage "usage: yaml_save [FILE]"
        return 2
    }

    [[ -n ${YAML_LIB_BUILD_STATE:-} && -f ${YAML_LIB_BUILD_STATE:-} ]] || {
        _yaml_err "no active YAML builder session"
        return 1
    }

    [[ -n $target_file ]] || {
        _yaml_err "no target file, call yaml_save FILE or start with yaml_begin_file"
        return 1
    }

    tmp_file=$(_yaml_mktemp_for "$target_file") || return 1
    if ! _yaml_emit_state_as_yaml "$YAML_LIB_BUILD_STATE" > "$tmp_file"; then
        rm -f -- "$tmp_file"
        return 1
    fi

    _yaml_move_into_place "$tmp_file" "$target_file"
    YAML_LIB_BUILD_FILE=$target_file
    YAML_LIB_SOURCE_TYPE="file"
    YAML_LIB_SOURCE_VALUE=$target_file
}

# API: yaml_close
# Usage: yaml_close
# Description:
#   Leave the current nested container and return to its parent.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if already at root or no builder session is active.
yaml_close() {
    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_close"
        return 2
    }

    _yaml_builder_pop_path_json
}

# API: yaml_new_object
# Usage: yaml_new_object KEY
# Description:
#   Create a new empty map under the current object container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not an object or no builder session is active.
yaml_new_object() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_new_object KEY"
        return 2
    }

    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; {})' --argjson path "$child_path" || return 1
    _yaml_builder_push_path_json "$child_path"
}

# API: yaml_new_array
# Usage: yaml_new_array KEY
# Description:
#   Create a new empty sequence under the current object container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not an object or no builder session is active.
yaml_new_array() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_new_array KEY"
        return 2
    }

    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; [])' --argjson path "$child_path" || return 1
    _yaml_builder_push_path_json "$child_path"
}

# API: yaml_add_string
# Usage: yaml_add_string KEY VALUE
# Description:
#   Add a string field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
yaml_add_string() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_add_string KEY VALUE"
        return 2
    }

    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --arg value "$2"
}

# API: yaml_add_int
# Usage: yaml_add_int KEY VALUE
# Description:
#   Add an integer field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid integer, wrong container type, or missing builder session.
yaml_add_int() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_add_int KEY VALUE"
        return 2
    }

    _yaml_validate_int "$2" || return 1
    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: yaml_add_float
# Usage: yaml_add_float KEY VALUE
# Description:
#   Add a floating-point field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid float, wrong container type, or missing builder session.
yaml_add_float() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_add_float KEY VALUE"
        return 2
    }

    _yaml_validate_float "$2" || return 1
    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: yaml_add_bool
# Usage: yaml_add_bool KEY {true|false}
# Description:
#   Add a boolean field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid boolean, wrong container type, or missing builder session.
yaml_add_bool() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _yaml_usage "usage: yaml_add_bool KEY {true|false}"
        return 2
    }

    _yaml_validate_bool "$2" || return 1
    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: yaml_add_null
# Usage: yaml_add_null KEY
# Description:
#   Add a null field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
yaml_add_null() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_add_null KEY"
        return 2
    }

    _yaml_builder_require_type object || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    child_path=$(_yaml_path_append_key "$path_json" "$1") || return 1

    _yaml_builder_apply 'setpath($path; null)' --argjson path "$child_path"
}

# API: yaml_push_object
# Usage: yaml_push_object
# Description:
#   Append a new empty object to the current array container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
yaml_push_object() {
    local path_json
    local index
    local child_path

    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_push_object"
        return 2
    }

    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    index=$(_yaml_builder_current_length) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [{}]))' --argjson path "$path_json" || return 1
    child_path=$(_yaml_path_append_index "$path_json" "$index") || return 1
    _yaml_builder_push_path_json "$child_path"
}

# API: yaml_push_array
# Usage: yaml_push_array
# Description:
#   Append a new empty array to the current array container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
yaml_push_array() {
    local path_json
    local index
    local child_path

    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_push_array"
        return 2
    }

    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    index=$(_yaml_builder_current_length) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [[]]))' --argjson path "$path_json" || return 1
    child_path=$(_yaml_path_append_index "$path_json" "$index") || return 1
    _yaml_builder_push_path_json "$child_path"
}

# API: yaml_push_string
# Usage: yaml_push_string VALUE
# Description:
#   Append a string value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
yaml_push_string() {
    local path_json

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_push_string VALUE"
        return 2
    }

    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --arg value "$1"
}

# API: yaml_push_int
# Usage: yaml_push_int VALUE
# Description:
#   Append an integer value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid integer, wrong container type, or missing builder session.
yaml_push_int() {
    local path_json

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_push_int VALUE"
        return 2
    }

    _yaml_validate_int "$1" || return 1
    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: yaml_push_float
# Usage: yaml_push_float VALUE
# Description:
#   Append a floating-point value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid float, wrong container type, or missing builder session.
yaml_push_float() {
    local path_json

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_push_float VALUE"
        return 2
    }

    _yaml_validate_float "$1" || return 1
    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: yaml_push_bool
# Usage: yaml_push_bool {true|false}
# Description:
#   Append a boolean value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid boolean, wrong container type, or missing builder session.
yaml_push_bool() {
    local path_json

    [[ $# -eq 1 ]] || {
        _yaml_usage "usage: yaml_push_bool {true|false}"
        return 2
    }

    _yaml_validate_bool "$1" || return 1
    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: yaml_push_null
# Usage: yaml_push_null
# Description:
#   Append a null value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
yaml_push_null() {
    local path_json

    [[ $# -eq 0 ]] || {
        _yaml_usage "usage: yaml_push_null"
        return 2
    }

    _yaml_builder_require_type array || return 1
    path_json=$(_yaml_builder_current_path_json) || return 1
    _yaml_builder_apply 'setpath($path; (getpath($path) + [null]))' --argjson path "$path_json"
}
