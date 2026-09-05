#!/usr/bin/env bash
# json_builder_lib.sh
# shellcheck shell=bash

if [[ -z ${BASH_VERSION:-} ]]; then
    printf 'json_builder_lib.sh: bash is required\n' >&2
    return 1 2>/dev/null || exit 1
fi

: "${JSON_LIB_JQ:=jq}"

JSON_LIB_SOURCE_TYPE=""
JSON_LIB_SOURCE_VALUE=""
JSON_LIB_BUILD_FILE=""
JSON_LIB_BUILD_STATE=""
JSON_LIB_BUILD_PATHS=()

_json_err() {
    printf 'json_lib: %s\n' "$*" >&2
}

_json_usage() {
    _json_err "$1"
    return 2
}

_json_cleanup_builder() {
    if [[ -n ${JSON_LIB_BUILD_STATE:-} && -f ${JSON_LIB_BUILD_STATE:-} ]]; then
        rm -f -- "$JSON_LIB_BUILD_STATE"
    fi

    JSON_LIB_BUILD_FILE=""
    JSON_LIB_BUILD_STATE=""
    JSON_LIB_BUILD_PATHS=()
}

_json_mktemp_for() {
    local target_file=$1
    local target_dir
    local target_base

    target_dir=$(dirname -- "$target_file") || return 1
    target_base=$(basename -- "$target_file") || return 1

    [[ -d $target_dir ]] || {
        _json_err "directory does not exist: $target_dir"
        return 1
    }

    mktemp "${target_dir}/.${target_base}.tmp.XXXXXX"
}

_json_mktemp_state() {
    mktemp "${TMPDIR:-/tmp}/json_lib.state.XXXXXX"
}

_json_move_into_place() {
    local src_file=$1
    local dst_file=$2
    mv -f -- "$src_file" "$dst_file"
}

_json_builder_path_count() {
    printf '%s' "${#JSON_LIB_BUILD_PATHS[@]}"
}

_json_builder_current_path_json() {
    local count
    count=$(_json_builder_path_count)

    [[ $count -gt 0 ]] || {
        _json_err "no active JSON builder session, call json_begin_file or json_begin_text first"
        return 1
    }

    printf '%s' "${JSON_LIB_BUILD_PATHS[$((count - 1))]}"
}

_json_builder_push_path_json() {
    JSON_LIB_BUILD_PATHS[${#JSON_LIB_BUILD_PATHS[@]}]=$1
}

_json_builder_pop_path_json() {
    local count
    count=$(_json_builder_path_count)

    [[ $count -gt 1 ]] || {
        _json_err "already at root container"
        return 1
    }

    unset 'JSON_LIB_BUILD_PATHS[$((count - 1))]'
}

_json_path_append_key() {
    local path_json=$1
    local key=$2

    "$JSON_LIB_JQ" -cn --argjson path "$path_json" --arg key "$key" '$path + [$key]'
}

_json_path_append_index() {
    local path_json=$1
    local index=$2

    "$JSON_LIB_JQ" -cn --argjson path "$path_json" --argjson index "$index" '$path + [$index]'
}

_json_builder_apply() {
    local jq_filter=$1
    shift

    local tmp_file

    [[ -n ${JSON_LIB_BUILD_STATE:-} && -f ${JSON_LIB_BUILD_STATE:-} ]] || {
        _json_err "no active JSON builder session, call json_begin_file or json_begin_text first"
        return 1
    }

    tmp_file=$(_json_mktemp_for "$JSON_LIB_BUILD_STATE") || return 1

    if ! "$JSON_LIB_JQ" "$@" "$jq_filter" "$JSON_LIB_BUILD_STATE" > "$tmp_file"; then
        rm -f -- "$tmp_file"
        return 1
    fi

    _json_move_into_place "$tmp_file" "$JSON_LIB_BUILD_STATE"
}

_json_builder_current_type() {
    local path_json

    path_json=$(_json_builder_current_path_json) || return 1
    "$JSON_LIB_JQ" -r --argjson path "$path_json" 'getpath($path) | type' "$JSON_LIB_BUILD_STATE"
}

_json_builder_require_type() {
    local expected_type=$1
    local actual_type

    actual_type=$(_json_builder_current_type) || return 1
    [[ $actual_type == "$expected_type" ]] || {
        _json_err "current container type is $actual_type, expected $expected_type"
        return 1
    }
}

_json_builder_current_length() {
    local path_json

    path_json=$(_json_builder_current_path_json) || return 1
    "$JSON_LIB_JQ" -r --argjson path "$path_json" 'getpath($path) | length' "$JSON_LIB_BUILD_STATE"
}

_json_builder_start_with_text() {
    local json_text=$1
    local state_file

    json_validate "$json_text" || return 1
    state_file=$(_json_mktemp_state) || return 1

    if ! printf '%s' "$json_text" | "$JSON_LIB_JQ" . > "$state_file"; then
        rm -f -- "$state_file"
        return 1
    fi

    _json_cleanup_builder
    JSON_LIB_BUILD_STATE=$state_file
    JSON_LIB_BUILD_PATHS=('[]')
}

_json_builder_root_type() {
    "$JSON_LIB_JQ" -r 'type' "$JSON_LIB_BUILD_STATE"
}

_json_validate_int() {
    [[ $1 =~ ^-?[0-9]+$ ]] || {
        _json_err "invalid integer: $1"
        return 1
    }
}

_json_validate_float() {
    [[ $1 =~ ^-?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$ ]] || {
        _json_err "invalid float: $1"
        return 1
    }
}

_json_validate_bool() {
    [[ $1 == "true" || $1 == "false" ]] || {
        _json_err "boolean value must be true or false"
        return 1
    }
}

# API: json_require_jq
# Usage: json_require_jq
# Description:
#   Check whether jq is available in PATH.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   127 if jq is not found.
json_require_jq() {
    command -v "$JSON_LIB_JQ" >/dev/null 2>&1 || {
        _json_err "jq is required but was not found in PATH"
        return 127
    }
}

# API: json_validate
# Usage: json_validate JSON_TEXT
# Description:
#   Validate whether a raw JSON string is syntactically valid JSON.
# Output:
#   No stdout output.
# Return:
#   0 if JSON_TEXT is valid JSON.
#   Non-zero otherwise.
json_validate() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_validate JSON_TEXT"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -e . >/dev/null
}

# API: json_validate_file
# Usage: json_validate_file FILE
# Description:
#   Validate whether a file contains syntactically valid JSON.
# Output:
#   No stdout output.
# Return:
#   0 if FILE contains valid JSON.
#   Non-zero otherwise.
json_validate_file() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_validate_file FILE"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e . "$1" >/dev/null
}

# API: json_validate_stdin
# Usage: json_validate_stdin
# Description:
#   Validate whether stdin contains syntactically valid JSON.
# Output:
#   No stdout output.
# Return:
#   0 if stdin contains valid JSON.
#   Non-zero otherwise.
json_validate_stdin() {
    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_validate_stdin"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e . >/dev/null
}

# API: json_file
# Usage: json_file FILE
# Description:
#   Set the current JSON source to a file for read APIs.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if FILE does not exist or is not valid JSON.
json_file() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_file FILE"
        return 2
    }

    [[ -f $1 ]] || {
        _json_err "file not found: $1"
        return 1
    }

    json_validate_file "$1" || {
        _json_err "invalid JSON file: $1"
        return 1
    }

    JSON_LIB_SOURCE_TYPE="file"
    JSON_LIB_SOURCE_VALUE=$1
}

# API: json_text
# Usage: json_text JSON_TEXT
# Description:
#   Set the current JSON source to a raw JSON string for read APIs.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if JSON_TEXT is not valid JSON.
json_text() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_text JSON_TEXT"
        return 2
    }

    json_validate "$1" || {
        _json_err "invalid JSON text"
        return 1
    }

    JSON_LIB_SOURCE_TYPE="text"
    JSON_LIB_SOURCE_VALUE=$1
}

# API: json_clear
# Usage: json_clear
# Description:
#   Clear the current read source and any active builder session.
# Output:
#   No stdout output.
# Return:
#   0 always.
json_clear() {
    JSON_LIB_SOURCE_TYPE=""
    JSON_LIB_SOURCE_VALUE=""
    _json_cleanup_builder
}

# API: json_info
# Usage: json_info
# Description:
#   Print current read source and builder target information.
# Output:
#   Prints lines describing the current source and builder state.
# Return:
#   0 on success.
json_info() {
    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_info"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            printf 'source_type=file\n'
            printf 'source_value=%s\n' "$JSON_LIB_SOURCE_VALUE"
            ;;
        text)
            printf 'source_type=text\n'
            printf 'source_value=%s\n' "$JSON_LIB_SOURCE_VALUE"
            ;;
        *)
            printf 'source_type=none\n'
            ;;
    esac

    if [[ -n ${JSON_LIB_BUILD_STATE:-} ]]; then
        printf 'builder=active\n'
        printf 'builder_file=%s\n' "$JSON_LIB_BUILD_FILE"
    else
        printf 'builder=none\n'
    fi
}

# API: json_query
# Usage: json_query JQ_FILTER
# Description:
#   Run a jq filter against the current JSON source and print compact JSON output.
# Output:
#   Prints compact JSON.
# Return:
#   0 on success.
#   Non-zero on missing source or jq failure.
json_query() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_query JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_query_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_query_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_get
# Usage: json_get JQ_FILTER
# Description:
#   Read a scalar value from the current JSON source.
#   Missing or null values are treated as errors.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing source, missing value, null value, or jq failure.
json_get() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_get JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_get_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_get_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_getd
# Usage: json_getd JQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from the current JSON source.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on missing source or jq failure.
json_getd() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_getd JQ_FILTER DEFAULT_TEXT"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_getd_from_file "$JSON_LIB_SOURCE_VALUE" "$1" "$2"
            ;;
        text)
            json_getd_from_text "$JSON_LIB_SOURCE_VALUE" "$1" "$2"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_has
# Usage: json_has JQ_FILTER
# Description:
#   Test whether the jq result from the current source is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
json_has() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_has JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_has_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_has_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_each
# Usage: json_each JQ_FILTER
# Description:
#   Iterate over an array from the current source.
#   Each element is printed as one compact JSON line.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on missing source or jq failure.
json_each() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_each JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_each_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_each_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_len
# Usage: json_len JQ_FILTER
# Description:
#   Print the length of the jq result from the current source.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on missing source or jq failure.
json_len() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_len JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_len_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_len_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_keys
# Usage: json_keys JQ_FILTER
# Description:
#   Print the keys of an object from the current source, one key per line.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on missing source or jq failure.
json_keys() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_keys JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_keys_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_keys_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_type
# Usage: json_type JQ_FILTER
# Description:
#   Print the jq type of the result from the current source.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on missing source or jq failure.
json_type() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_type JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_type_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_type_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_true
# Usage: json_true JQ_FILTER
# Description:
#   Test whether the jq result from the current source is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
json_true() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_true JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_true_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_true_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_false
# Usage: json_false JQ_FILTER
# Description:
#   Test whether the jq result from the current source is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
json_false() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_false JQ_FILTER"
        return 2
    }

    case $JSON_LIB_SOURCE_TYPE in
        file)
            json_false_from_file "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            json_false_from_text "$JSON_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _json_err "no current JSON source, call json_file or json_text first"
            return 1
            ;;
    esac
}

# API: json_query_from_file
# Usage: json_query_from_file FILE JQ_FILTER
# Description:
#   Run a jq filter against a specific JSON file and print compact JSON output.
# Output:
#   Prints compact JSON.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_query_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_query_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -c "$2" "$1"
}

# API: json_query_from_text
# Usage: json_query_from_text JSON_TEXT JQ_FILTER
# Description:
#   Run a jq filter against a raw JSON string and print compact JSON output.
# Output:
#   Prints compact JSON.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_query_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_query_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -c "$2"
}

# API: json_query_from_stdin
# Usage: json_query_from_stdin JQ_FILTER
# Description:
#   Run a jq filter against JSON read from stdin and print compact JSON output.
# Output:
#   Prints compact JSON.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_query_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_query_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -c "$1"
}

# API: json_get_from_file
# Usage: json_get_from_file FILE JQ_FILTER
# Description:
#   Read a scalar value from a specific JSON file.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing value, null value, or jq failure.
json_get_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_get_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -er "(($2) as \$value | if \$value == null then error(\"missing or null\") else \$value end)" "$1"
}

# API: json_get_from_text
# Usage: json_get_from_text JSON_TEXT JQ_FILTER
# Description:
#   Read a scalar value from a raw JSON string.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing value, null value, or jq failure.
json_get_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_get_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -er "(($2) as \$value | if \$value == null then error(\"missing or null\") else \$value end)"
}

# API: json_get_from_stdin
# Usage: json_get_from_stdin JQ_FILTER
# Description:
#   Read a scalar value from JSON provided on stdin.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing value, null value, or jq failure.
json_get_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_get_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -er "(($1) as \$value | if \$value == null then error(\"missing or null\") else \$value end)"
}

# API: json_getd_from_file
# Usage: json_getd_from_file FILE JQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from a specific JSON file.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_getd_from_file() {
    [[ $# -eq 3 ]] || {
        _json_usage "usage: json_getd_from_file FILE JQ_FILTER DEFAULT_TEXT"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -r --arg default "$3" "((($2) as \$value | if \$value == null then \$default else \$value end))" "$1"
}

# API: json_getd_from_text
# Usage: json_getd_from_text JSON_TEXT JQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from a raw JSON string.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_getd_from_text() {
    [[ $# -eq 3 ]] || {
        _json_usage "usage: json_getd_from_text JSON_TEXT JQ_FILTER DEFAULT_TEXT"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -r --arg default "$3" "((($2) as \$value | if \$value == null then \$default else \$value end))"
}

# API: json_getd_from_stdin
# Usage: json_getd_from_stdin JQ_FILTER DEFAULT_TEXT
# Description:
#   Read a scalar value from JSON provided on stdin.
#   If the value is missing or null, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_getd_from_stdin() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_getd_from_stdin JQ_FILTER DEFAULT_TEXT"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -r --arg default "$2" "((($1) as \$value | if \$value == null then \$default else \$value end))"
}

# API: json_has_from_file
# Usage: json_has_from_file FILE JQ_FILTER
# Description:
#   Test whether the jq result from a specific JSON file is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
json_has_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_has_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e "(($2) != null)" "$1" >/dev/null
}

# API: json_has_from_text
# Usage: json_has_from_text JSON_TEXT JQ_FILTER
# Description:
#   Test whether the jq result from a raw JSON string is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
json_has_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_has_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -e "(($2) != null)" >/dev/null
}

# API: json_has_from_stdin
# Usage: json_has_from_stdin JQ_FILTER
# Description:
#   Test whether the jq result from JSON on stdin is not null.
# Output:
#   No stdout output.
# Return:
#   0 if the result exists and is not null.
#   Non-zero otherwise.
json_has_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_has_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e "(($1) != null)" >/dev/null
}

# API: json_each_from_file
# Usage: json_each_from_file FILE JQ_FILTER
# Description:
#   Iterate over an array from a specific JSON file.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_each_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_each_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -c "$2[]" "$1"
}

# API: json_each_from_text
# Usage: json_each_from_text JSON_TEXT JQ_FILTER
# Description:
#   Iterate over an array from a raw JSON string.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_each_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_each_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -c "$2[]"
}

# API: json_each_from_stdin
# Usage: json_each_from_stdin JQ_FILTER
# Description:
#   Iterate over an array from JSON on stdin.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_each_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_each_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -c "$1[]"
}

# API: json_len_from_file
# Usage: json_len_from_file FILE JQ_FILTER
# Description:
#   Print the length of the jq result from a specific JSON file.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_len_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_len_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -er "$2 | length" "$1"
}

# API: json_len_from_text
# Usage: json_len_from_text JSON_TEXT JQ_FILTER
# Description:
#   Print the length of the jq result from a raw JSON string.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_len_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_len_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -er "$2 | length"
}

# API: json_len_from_stdin
# Usage: json_len_from_stdin JQ_FILTER
# Description:
#   Print the length of the jq result from JSON on stdin.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_len_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_len_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -er "$1 | length"
}

# API: json_keys_from_file
# Usage: json_keys_from_file FILE JQ_FILTER
# Description:
#   Print the keys of an object from a specific JSON file.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_keys_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_keys_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -r "$2 | keys[]" "$1"
}

# API: json_keys_from_text
# Usage: json_keys_from_text JSON_TEXT JQ_FILTER
# Description:
#   Print the keys of an object from a raw JSON string.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_keys_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_keys_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -r "$2 | keys[]"
}

# API: json_keys_from_stdin
# Usage: json_keys_from_stdin JQ_FILTER
# Description:
#   Print the keys of an object from JSON on stdin.
# Output:
#   Prints keys, one per line.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_keys_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_keys_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -r "$1 | keys[]"
}

# API: json_type_from_file
# Usage: json_type_from_file FILE JQ_FILTER
# Description:
#   Print the jq type of the result from a specific JSON file.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_type_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_type_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -r "$2 | type" "$1"
}

# API: json_type_from_text
# Usage: json_type_from_text JSON_TEXT JQ_FILTER
# Description:
#   Print the jq type of the result from a raw JSON string.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_type_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_type_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -r "$2 | type"
}

# API: json_type_from_stdin
# Usage: json_type_from_stdin JQ_FILTER
# Description:
#   Print the jq type of the result from JSON on stdin.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on jq failure.
json_type_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_type_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -r "$1 | type"
}

# API: json_true_from_file
# Usage: json_true_from_file FILE JQ_FILTER
# Description:
#   Test whether the jq result from a specific JSON file is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
json_true_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_true_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e "(($2) == true)" "$1" >/dev/null
}

# API: json_true_from_text
# Usage: json_true_from_text JSON_TEXT JQ_FILTER
# Description:
#   Test whether the jq result from a raw JSON string is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
json_true_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_true_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -e "(($2) == true)" >/dev/null
}

# API: json_true_from_stdin
# Usage: json_true_from_stdin JQ_FILTER
# Description:
#   Test whether the jq result from JSON on stdin is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly true.
#   Non-zero otherwise.
json_true_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_true_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e "(($1) == true)" >/dev/null
}

# API: json_false_from_file
# Usage: json_false_from_file FILE JQ_FILTER
# Description:
#   Test whether the jq result from a specific JSON file is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
json_false_from_file() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_false_from_file FILE JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e "(($2) == false)" "$1" >/dev/null
}

# API: json_false_from_text
# Usage: json_false_from_text JSON_TEXT JQ_FILTER
# Description:
#   Test whether the jq result from a raw JSON string is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
json_false_from_text() {
    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_false_from_text JSON_TEXT JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    printf '%s' "$1" | "$JSON_LIB_JQ" -e "(($2) == false)" >/dev/null
}

# API: json_false_from_stdin
# Usage: json_false_from_stdin JQ_FILTER
# Description:
#   Test whether the jq result from JSON on stdin is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the result is exactly false.
#   Non-zero otherwise.
json_false_from_stdin() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_false_from_stdin JQ_FILTER"
        return 2
    }

    json_require_jq || return $?
    "$JSON_LIB_JQ" -e "(($1) == false)" >/dev/null
}

# API: json_begin_file
# Usage: json_begin_file FILE
# Description:
#   Start a builder session backed by FILE.
#   If FILE exists and is valid JSON, it is loaded.
#   If FILE does not exist or is empty, a new empty object is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on parse failure or builder setup failure.
json_begin_file() {
    local target_file
    local state_file

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_begin_file FILE"
        return 2
    }

    target_file=$1

    json_require_jq || return $?

    state_file=$(_json_mktemp_state) || return 1

    if [[ -f $target_file && -s $target_file ]]; then
        if ! "$JSON_LIB_JQ" . "$target_file" > "$state_file"; then
            rm -f -- "$state_file"
            return 1
        fi
    else
        printf '{}\n' > "$state_file"
    fi

    _json_cleanup_builder
    JSON_LIB_BUILD_FILE=$target_file
    JSON_LIB_BUILD_STATE=$state_file
    JSON_LIB_BUILD_PATHS=('[]')

    JSON_LIB_SOURCE_TYPE="file"
    JSON_LIB_SOURCE_VALUE=$target_file
}

# API: json_begin_text
# Usage: json_begin_text JSON_TEXT
# Description:
#   Start a builder session from raw JSON text.
#   This session has no output file until json_save FILE is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on parse failure or builder setup failure.
json_begin_text() {
    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_begin_text JSON_TEXT"
        return 2
    }

    json_require_jq || return $?
    _json_builder_start_with_text "$1" || return 1

    JSON_LIB_SOURCE_TYPE="text"
    JSON_LIB_SOURCE_VALUE=$1
}

# API: json_reset
# Usage: json_reset [object|array]
# Description:
#   Reset the active builder session to an empty root container.
#   The default root type is object.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid usage or missing builder session.
json_reset() {
    local root_type=${1:-object}

    [[ $# -le 1 ]] || {
        _json_usage "usage: json_reset [object|array]"
        return 2
    }

    json_require_jq || return $?

    [[ -n ${JSON_LIB_BUILD_STATE:-} ]] || {
        _json_err "no active JSON builder session"
        return 1
    }

    case $root_type in
        object)
            printf '{}\n' > "$JSON_LIB_BUILD_STATE"
            ;;
        array)
            printf '[]\n' > "$JSON_LIB_BUILD_STATE"
            ;;
        *)
            _json_err "root type must be object or array"
            return 1
            ;;
    esac

    JSON_LIB_BUILD_PATHS=('[]')
}

# API: json_print
# Usage: json_print
# Description:
#   Print the current builder document as pretty JSON.
# Output:
#   Prints the current builder JSON document.
# Return:
#   0 on success.
#   Non-zero on missing builder session.
json_print() {
    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_print"
        return 2
    }

    [[ -n ${JSON_LIB_BUILD_STATE:-} && -f ${JSON_LIB_BUILD_STATE:-} ]] || {
        _json_err "no active JSON builder session"
        return 1
    }

    "$JSON_LIB_JQ" . "$JSON_LIB_BUILD_STATE"
}

# API: json_save
# Usage: json_save [FILE]
# Description:
#   Save the current builder document to FILE.
#   If FILE is omitted, the file passed to json_begin_file is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on missing builder session or save failure.
json_save() {
    local target_file=${1:-$JSON_LIB_BUILD_FILE}
    local tmp_file

    [[ $# -le 1 ]] || {
        _json_usage "usage: json_save [FILE]"
        return 2
    }

    [[ -n ${JSON_LIB_BUILD_STATE:-} && -f ${JSON_LIB_BUILD_STATE:-} ]] || {
        _json_err "no active JSON builder session"
        return 1
    }

    [[ -n $target_file ]] || {
        _json_err "no target file, call json_save FILE or start with json_begin_file"
        return 1
    }

    tmp_file=$(_json_mktemp_for "$target_file") || return 1
    if ! "$JSON_LIB_JQ" . "$JSON_LIB_BUILD_STATE" > "$tmp_file"; then
        rm -f -- "$tmp_file"
        return 1
    fi

    _json_move_into_place "$tmp_file" "$target_file"
    JSON_LIB_BUILD_FILE=$target_file
    JSON_LIB_SOURCE_TYPE="file"
    JSON_LIB_SOURCE_VALUE=$target_file
}

# API: json_close
# Usage: json_close
# Description:
#   Leave the current nested container and return to its parent.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if already at root or no builder session is active.
json_close() {
    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_close"
        return 2
    }

    _json_builder_pop_path_json
}

# API: json_new_object
# Usage: json_new_object KEY
# Description:
#   Create a new empty object under the current object container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not an object or no builder session is active.
json_new_object() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_new_object KEY"
        return 2
    }

    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; {})' --argjson path "$child_path" || return 1
    _json_builder_push_path_json "$child_path"
}

# API: json_new_array
# Usage: json_new_array KEY
# Description:
#   Create a new empty array under the current object container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not an object or no builder session is active.
json_new_array() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_new_array KEY"
        return 2
    }

    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; [])' --argjson path "$child_path" || return 1
    _json_builder_push_path_json "$child_path"
}

# API: json_add_string
# Usage: json_add_string KEY VALUE
# Description:
#   Add a string field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not an object or no builder session is active.
json_add_string() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_add_string KEY VALUE"
        return 2
    }

    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --arg value "$2"
}

# API: json_add_int
# Usage: json_add_int KEY VALUE
# Description:
#   Add an integer field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid integer, wrong container type, or missing builder session.
json_add_int() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_add_int KEY VALUE"
        return 2
    }

    _json_validate_int "$2" || return 1
    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: json_add_float
# Usage: json_add_float KEY VALUE
# Description:
#   Add a floating-point field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid float, wrong container type, or missing builder session.
json_add_float() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_add_float KEY VALUE"
        return 2
    }

    _json_validate_float "$2" || return 1
    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: json_add_bool
# Usage: json_add_bool KEY {true|false}
# Description:
#   Add a boolean field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid boolean, wrong container type, or missing builder session.
json_add_bool() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _json_usage "usage: json_add_bool KEY {true|false}"
        return 2
    }

    _json_validate_bool "$2" || return 1
    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: json_add_null
# Usage: json_add_null KEY
# Description:
#   Add a null field to the current object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
json_add_null() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_add_null KEY"
        return 2
    }

    _json_builder_require_type object || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    child_path=$(_json_path_append_key "$path_json" "$1") || return 1

    _json_builder_apply 'setpath($path; null)' --argjson path "$child_path"
}

# API: json_push_object
# Usage: json_push_object
# Description:
#   Append a new empty object to the current array container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
json_push_object() {
    local path_json
    local index
    local child_path

    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_push_object"
        return 2
    }

    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    index=$(_json_builder_current_length) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [{}]))' --argjson path "$path_json" || return 1
    child_path=$(_json_path_append_index "$path_json" "$index") || return 1
    _json_builder_push_path_json "$child_path"
}

# API: json_push_array
# Usage: json_push_array
# Description:
#   Append a new empty array to the current array container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
json_push_array() {
    local path_json
    local index
    local child_path

    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_push_array"
        return 2
    }

    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    index=$(_json_builder_current_length) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [[]]))' --argjson path "$path_json" || return 1
    child_path=$(_json_path_append_index "$path_json" "$index") || return 1
    _json_builder_push_path_json "$child_path"
}

# API: json_push_string
# Usage: json_push_string VALUE
# Description:
#   Append a string value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
json_push_string() {
    local path_json

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_push_string VALUE"
        return 2
    }

    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --arg value "$1"
}

# API: json_push_int
# Usage: json_push_int VALUE
# Description:
#   Append an integer value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid integer, wrong container type, or missing builder session.
json_push_int() {
    local path_json

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_push_int VALUE"
        return 2
    }

    _json_validate_int "$1" || return 1
    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: json_push_float
# Usage: json_push_float VALUE
# Description:
#   Append a floating-point value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid float, wrong container type, or missing builder session.
json_push_float() {
    local path_json

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_push_float VALUE"
        return 2
    }

    _json_validate_float "$1" || return 1
    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: json_push_bool
# Usage: json_push_bool {true|false}
# Description:
#   Append a boolean value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid boolean, wrong container type, or missing builder session.
json_push_bool() {
    local path_json

    [[ $# -eq 1 ]] || {
        _json_usage "usage: json_push_bool {true|false}"
        return 2
    }

    _json_validate_bool "$1" || return 1
    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: json_push_null
# Usage: json_push_null
# Description:
#   Append a null value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
json_push_null() {
    local path_json

    [[ $# -eq 0 ]] || {
        _json_usage "usage: json_push_null"
        return 2
    }

    _json_builder_require_type array || return 1
    path_json=$(_json_builder_current_path_json) || return 1
    _json_builder_apply 'setpath($path; (getpath($path) + [null]))' --argjson path "$path_json"
}
