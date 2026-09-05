#!/usr/bin/env bash
# toml_builder_lib.sh
# shellcheck shell=bash

if [[ -z ${BASH_VERSION:-} ]]; then
    printf 'toml_builder_lib.sh: bash is required\n' >&2
    return 1 2>/dev/null || exit 1
fi

: "${TOML_LIB_PYTHON:=python3}"
: "${TOML_LIB_JQ:=jq}"

TOML_LIB_SOURCE_TYPE=""
TOML_LIB_SOURCE_VALUE=""
TOML_LIB_BUILD_FILE=""
TOML_LIB_BUILD_STATE=""
TOML_LIB_BUILD_PATHS=()

_toml_err() {
    printf 'toml_lib: %s\n' "$*" >&2
}

_toml_usage() {
    _toml_err "$1"
    return 2
}

_toml_cleanup_builder() {
    if [[ -n ${TOML_LIB_BUILD_STATE:-} && -f ${TOML_LIB_BUILD_STATE:-} ]]; then
        rm -f -- "$TOML_LIB_BUILD_STATE"
    fi

    TOML_LIB_BUILD_FILE=""
    TOML_LIB_BUILD_STATE=""
    TOML_LIB_BUILD_PATHS=()
}

_toml_mktemp_for() {
    local target_file=$1
    local target_dir
    local target_base

    target_dir=$(dirname -- "$target_file") || return 1
    target_base=$(basename -- "$target_file") || return 1

    [[ -d $target_dir ]] || {
        _toml_err "directory does not exist: $target_dir"
        return 1
    }

    mktemp "${target_dir}/.${target_base}.tmp.XXXXXX"
}

_toml_mktemp_state() {
    mktemp "${TMPDIR:-/tmp}/toml_lib.state.XXXXXX"
}

_toml_move_into_place() {
    local src_file=$1
    local dst_file=$2
    mv -f -- "$src_file" "$dst_file"
}

_toml_path_count() {
    printf '%s' "${#TOML_LIB_BUILD_PATHS[@]}"
}

_toml_current_path_json() {
    local count
    count=$(_toml_path_count)

    [[ $count -gt 0 ]] || {
        _toml_err "no active TOML builder session, call toml_begin_file or toml_begin_text first"
        return 1
    }

    printf '%s' "${TOML_LIB_BUILD_PATHS[$((count - 1))]}"
}

_toml_push_path_json() {
    TOML_LIB_BUILD_PATHS[${#TOML_LIB_BUILD_PATHS[@]}]=$1
}

_toml_pop_path_json() {
    local count
    count=$(_toml_path_count)

    [[ $count -gt 1 ]] || {
        _toml_err "already at root container"
        return 1
    }

    unset 'TOML_LIB_BUILD_PATHS[$((count - 1))]'
}

_toml_path_append_key() {
    local path_json=$1
    local key=$2

    "$TOML_LIB_JQ" -cn --argjson path "$path_json" --arg key "$key" '$path + [$key]'
}

_toml_path_append_index() {
    local path_json=$1
    local index=$2

    "$TOML_LIB_JQ" -cn --argjson path "$path_json" --argjson index "$index" '$path + [$index]'
}

_toml_apply() {
    local jq_filter=$1
    shift

    local tmp_file

    [[ -n ${TOML_LIB_BUILD_STATE:-} && -f ${TOML_LIB_BUILD_STATE:-} ]] || {
        _toml_err "no active TOML builder session, call toml_begin_file or toml_begin_text first"
        return 1
    }

    tmp_file=$(_toml_mktemp_for "$TOML_LIB_BUILD_STATE") || return 1

    if ! "$TOML_LIB_JQ" "$@" "$jq_filter" "$TOML_LIB_BUILD_STATE" > "$tmp_file"; then
        rm -f -- "$tmp_file"
        return 1
    fi

    _toml_move_into_place "$tmp_file" "$TOML_LIB_BUILD_STATE"
}

_toml_current_type() {
    local path_json

    path_json=$(_toml_current_path_json) || return 1
    "$TOML_LIB_JQ" -r --argjson path "$path_json" 'getpath($path) | type' "$TOML_LIB_BUILD_STATE"
}

_toml_require_type() {
    local expected_type=$1
    local actual_type

    actual_type=$(_toml_current_type) || return 1
    [[ $actual_type == "$expected_type" ]] || {
        _toml_err "current container type is $actual_type, expected $expected_type"
        return 1
    }
}

_toml_current_length() {
    local path_json

    path_json=$(_toml_current_path_json) || return 1
    "$TOML_LIB_JQ" -r --argjson path "$path_json" 'getpath($path) | length' "$TOML_LIB_BUILD_STATE"
}

_toml_validate_int() {
    [[ $1 =~ ^-?[0-9]+$ ]] || {
        _toml_err "invalid integer: $1"
        return 1
    }
}

_toml_validate_float() {
    [[ $1 =~ ^-?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$ ]] || {
        _toml_err "invalid float: $1"
        return 1
    }
}

_toml_validate_bool() {
    [[ $1 == "true" || $1 == "false" ]] || {
        _toml_err "boolean value must be true or false"
        return 1
    }
}

_toml_run_py() {
    "$TOML_LIB_PYTHON" -c "$(cat <<'PY'
import ast
import datetime
import json
import os
import sys
from collections.abc import Mapping


def die(message, code=1):
    sys.stderr.write(f"toml_lib: {message}\n")
    raise SystemExit(code)


def require_reader():
    try:
        import tomllib  # type: ignore
        return tomllib
    except ModuleNotFoundError:
        try:
            import tomli as tomllib  # type: ignore
            return tomllib
        except ModuleNotFoundError:
            die("python tomllib (Python 3.11+) or third-party tomli is required", 127)


def require_writer():
    try:
        import tomlkit  # type: ignore
        return tomlkit
    except ModuleNotFoundError:
        die("tomlkit is required for TOML write operations", 127)


def load_toml_source():
    source = os.environ.get("TOML_LIB_SOURCE", "")

    if source == "file":
        path = os.environ["TOML_LIB_FILE"]
        with open(path, "rb") as file_obj:
            return file_obj.read()

    if source == "text":
        return os.environ.get("TOML_LIB_TEXT", "").encode("utf-8")

    if source == "stdin":
        return sys.stdin.buffer.read()

    die("internal error: invalid source type")


def load_toml_document():
    tomllib = require_reader()
    raw = load_toml_source()

    try:
        return tomllib.loads(raw.decode("utf-8"))
    except Exception as exc:
        die(str(exc))


def parse_path(path_text):
    if path_text is None or path_text == "" or path_text == ".":
        return []

    tokens = []
    index = 0
    length = len(path_text)

    if path_text.startswith("."):
        index = 1

    while index < length:
        char = path_text[index]

        if char == ".":
            index += 1
            continue

        if char == "[":
            inner_start = index + 1
            cursor = inner_start
            quote = None
            escape = False

            while cursor < length:
                current = path_text[cursor]

                if quote is not None:
                    if escape:
                        escape = False
                    elif current == "\\":
                        escape = True
                    elif current == quote:
                        quote = None
                else:
                    if current in ("\"", "'"):
                        quote = current
                    elif current == "]":
                        break

                cursor += 1

            if cursor >= length or path_text[cursor] != "]":
                die(f"invalid path: {path_text}")

            inner = path_text[inner_start:cursor].strip()
            if inner == "":
                die(f"invalid path: {path_text}")

            if inner[0] in ("\"", "'") and inner[-1] == inner[0]:
                try:
                    key = ast.literal_eval(inner)
                except Exception:
                    die(f"invalid quoted key in path: {path_text}")

                if not isinstance(key, str):
                    die(f"invalid quoted key in path: {path_text}")

                tokens.append(key)
            else:
                try:
                    array_index = int(inner, 10)
                except ValueError:
                    die("bracket segment must be an integer index or quoted key")

                tokens.append(array_index)

            index = cursor + 1
            continue

        cursor = index
        while cursor < length and path_text[cursor] not in ".[":
            cursor += 1

        key = path_text[index:cursor]
        if key == "":
            die(f"invalid path: {path_text}")

        tokens.append(key)
        index = cursor

    return tokens


def is_mapping_like(value):
    return isinstance(value, Mapping)


def is_sequence_like(value):
    return isinstance(value, list)


def get_path_value(root_value, path_tokens):
    current = root_value

    for token in path_tokens:
        if isinstance(token, str):
            if not is_mapping_like(current):
                die("path does not point to a table before key access")

            if token not in current:
                die("missing path")

            current = current[token]
            continue

        if not is_sequence_like(current):
            die("path does not point to an array before index access")

        if token < 0 or token >= len(current):
            die("array index out of range")

        current = current[token]

    return current


def try_get_path_value(root_value, path_tokens):
    current = root_value

    for token in path_tokens:
        if isinstance(token, str):
            if not is_mapping_like(current) or token not in current:
                return None, False

            current = current[token]
            continue

        if not is_sequence_like(current) or token < 0 or token >= len(current):
            return None, False

        current = current[token]

    return current, True


def to_jsonable(value):
    if is_mapping_like(value):
        return {str(key): to_jsonable(item) for key, item in value.items()}

    if is_sequence_like(value):
        return [to_jsonable(item) for item in value]

    if isinstance(value, (datetime.datetime, datetime.date, datetime.time)):
        return value.isoformat()

    return value


def scalar_to_text(value):
    if isinstance(value, bool):
        return "true" if value else "false"

    if isinstance(value, (datetime.datetime, datetime.date, datetime.time)):
        return value.isoformat()

    return str(value)


def toml_type_name(value):
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int) and not isinstance(value, bool):
        return "integer"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        return "string"
    if isinstance(value, datetime.datetime):
        return "datetime"
    if isinstance(value, datetime.date) and not isinstance(value, datetime.datetime):
        return "date"
    if isinstance(value, datetime.time):
        return "time"
    if is_sequence_like(value):
        return "array"
    if is_mapping_like(value):
        return "table"
    return type(value).__name__


def dump_loaded_source_as_json():
    data = load_toml_document()
    sys.stdout.write(json.dumps(to_jsonable(data), ensure_ascii=False, separators=(",", ":")))


def dump_json_state_as_toml():
    tomlkit = require_writer()
    state_file = os.environ["TOML_LIB_STATE_FILE"]

    with open(state_file, "r", encoding="utf-8") as file_obj:
        data = json.load(file_obj)

    if not isinstance(data, dict):
        die("TOML root must be an object/table")

    sys.stdout.write(tomlkit.dumps(data))


operation = os.environ.get("TOML_LIB_OP", "")
path_tokens = parse_path(os.environ.get("TOML_LIB_PATH", "."))

if operation == "require_read":
    require_reader()
    raise SystemExit(0)

if operation == "require_write":
    require_writer()
    raise SystemExit(0)

if operation == "validate":
    load_toml_document()
    raise SystemExit(0)

if operation == "load_as_json":
    dump_loaded_source_as_json()
    raise SystemExit(0)

if operation == "save_from_json":
    dump_json_state_as_toml()
    raise SystemExit(0)

if operation in {"query", "get", "getd", "has", "each", "len", "keys", "type", "true", "false"}:
    document = load_toml_document()

    if operation == "getd":
        default_text = os.environ.get("TOML_LIB_DEFAULT", "")
        value, exists = try_get_path_value(document, path_tokens)
        if not exists:
            sys.stdout.write(default_text)
            raise SystemExit(0)
    elif operation == "has":
        _, exists = try_get_path_value(document, path_tokens)
        raise SystemExit(0 if exists else 1)
    else:
        value = get_path_value(document, path_tokens)

    if operation == "query":
        sys.stdout.write(json.dumps(to_jsonable(value), ensure_ascii=False, separators=(",", ":")))
        raise SystemExit(0)

    if operation == "get":
        if is_mapping_like(value) or is_sequence_like(value):
            die("toml_get only supports scalar values")
        sys.stdout.write(scalar_to_text(value))
        raise SystemExit(0)

    if operation == "getd":
        if is_mapping_like(value) or is_sequence_like(value):
            die("toml_getd only supports scalar values")
        sys.stdout.write(scalar_to_text(value))
        raise SystemExit(0)

    if operation == "each":
        if not is_sequence_like(value):
            die("toml_each requires an array value")
        for item in value:
            sys.stdout.write(json.dumps(to_jsonable(item), ensure_ascii=False, separators=(",", ":")))
            sys.stdout.write("\n")
        raise SystemExit(0)

    if operation == "len":
        if not (is_mapping_like(value) or is_sequence_like(value) or isinstance(value, str)):
            die("toml_len requires a table, array, or string")
        sys.stdout.write(str(len(value)))
        raise SystemExit(0)

    if operation == "keys":
        if is_mapping_like(value):
            for key in value.keys():
                sys.stdout.write(str(key))
                sys.stdout.write("\n")
            raise SystemExit(0)

        if is_sequence_like(value):
            for index in range(len(value)):
                sys.stdout.write(str(index))
                sys.stdout.write("\n")
            raise SystemExit(0)

        die("toml_keys requires a table or array")

    if operation == "type":
        sys.stdout.write(toml_type_name(value))
        raise SystemExit(0)

    if operation == "true":
        raise SystemExit(0 if value is True else 1)

    if operation == "false":
        raise SystemExit(0 if value is False else 1)

die("internal error: unknown operation")
PY
)"
}

# API: toml_require_python
# Usage: toml_require_python
# Description:
#   Check whether python3 is available in PATH.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   127 if python3 is not found.
toml_require_python() {
    command -v "$TOML_LIB_PYTHON" >/dev/null 2>&1 || {
        _toml_err "python3 is required but was not found in PATH"
        return 127
    }
}

# API: toml_require_jq
# Usage: toml_require_jq
# Description:
#   Check whether jq is available in PATH.
#   jq is used internally by the builder implementation.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   127 if jq is not found.
toml_require_jq() {
    command -v "$TOML_LIB_JQ" >/dev/null 2>&1 || {
        _toml_err "jq is required but was not found in PATH"
        return 127
    }
}

# API: toml_require_read
# Usage: toml_require_read
# Description:
#   Check whether TOML read support is available.
#   This requires python3 and either tomllib (Python 3.11+) or tomli.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on missing dependency.
toml_require_read() {
    toml_require_python || return $?
    TOML_LIB_OP=require_read _toml_run_py >/dev/null
}

# API: toml_require_write
# Usage: toml_require_write
# Description:
#   Check whether TOML write support is available.
#   This requires python3 and tomlkit.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on missing dependency.
toml_require_write() {
    toml_require_python || return $?
    TOML_LIB_OP=require_write _toml_run_py >/dev/null
}

# API: toml_validate
# Usage: toml_validate TOML_TEXT
# Description:
#   Validate whether a raw TOML string is syntactically valid TOML.
# Output:
#   No stdout output.
# Return:
#   0 if TOML_TEXT is valid TOML.
#   Non-zero otherwise.
toml_validate() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_validate TOML_TEXT"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_OP=validate _toml_run_py >/dev/null
}

# API: toml_validate_file
# Usage: toml_validate_file FILE
# Description:
#   Validate whether a file contains syntactically valid TOML.
# Output:
#   No stdout output.
# Return:
#   0 if FILE contains valid TOML.
#   Non-zero otherwise.
toml_validate_file() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_validate_file FILE"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_OP=validate _toml_run_py >/dev/null
}

# API: toml_validate_stdin
# Usage: toml_validate_stdin
# Description:
#   Validate whether stdin contains syntactically valid TOML.
# Output:
#   No stdout output.
# Return:
#   0 if stdin contains valid TOML.
#   Non-zero otherwise.
toml_validate_stdin() {
    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_validate_stdin"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_OP=validate _toml_run_py >/dev/null
}

# API: toml_file
# Usage: toml_file FILE
# Description:
#   Set the current TOML source to a file for read APIs.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if FILE does not exist or is not valid TOML.
toml_file() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_file FILE"
        return 2
    }

    [[ -f $1 ]] || {
        _toml_err "file not found: $1"
        return 1
    }

    toml_validate_file "$1" || {
        _toml_err "invalid TOML file: $1"
        return 1
    }

    TOML_LIB_SOURCE_TYPE="file"
    TOML_LIB_SOURCE_VALUE=$1
}

# API: toml_text
# Usage: toml_text TOML_TEXT
# Description:
#   Set the current TOML source to raw TOML text for read APIs.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if TOML_TEXT is not valid TOML.
toml_text() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_text TOML_TEXT"
        return 2
    }

    toml_validate "$1" || {
        _toml_err "invalid TOML text"
        return 1
    }

    TOML_LIB_SOURCE_TYPE="text"
    TOML_LIB_SOURCE_VALUE=$1
}

# API: toml_clear
# Usage: toml_clear
# Description:
#   Clear the current read source and any active builder session.
# Output:
#   No stdout output.
# Return:
#   0 always.
toml_clear() {
    TOML_LIB_SOURCE_TYPE=""
    TOML_LIB_SOURCE_VALUE=""
    _toml_cleanup_builder
}

# API: toml_info
# Usage: toml_info
# Description:
#   Print current read source and builder target information.
# Output:
#   Prints lines describing the current source and builder state.
# Return:
#   0 on success.
toml_info() {
    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_info"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            printf 'source_type=file\n'
            printf 'source_value=%s\n' "$TOML_LIB_SOURCE_VALUE"
            ;;
        text)
            printf 'source_type=text\n'
            printf 'source_value=%s\n' "$TOML_LIB_SOURCE_VALUE"
            ;;
        *)
            printf 'source_type=none\n'
            ;;
    esac

    if [[ -n ${TOML_LIB_BUILD_STATE:-} ]]; then
        printf 'builder=active\n'
        printf 'builder_file=%s\n' "$TOML_LIB_BUILD_FILE"
    else
        printf 'builder=none\n'
    fi
}

# API: toml_query
# Usage: toml_query PATH
# Description:
#   Query the current TOML source using a simple path syntax such as:
#     .server.port
#     .users[0].name
#     .["tool.poetry"].version
#   The result is printed as compact JSON.
# Output:
#   Prints the selected value as compact JSON.
# Return:
#   0 on success.
#   Non-zero on missing source, invalid path, or parse failure.
toml_query() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_query PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_query_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_query_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_get
# Usage: toml_get PATH
# Description:
#   Read a scalar value from the current TOML source.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing source, missing path, non-scalar result, or parse failure.
toml_get() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_get PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_get_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_get_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_getd
# Usage: toml_getd PATH DEFAULT_TEXT
# Description:
#   Read a scalar value from the current TOML source.
#   If the path is missing, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on missing source, non-scalar result, or parse failure.
toml_getd() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_getd PATH DEFAULT_TEXT"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_getd_from_file "$TOML_LIB_SOURCE_VALUE" "$1" "$2"
            ;;
        text)
            toml_getd_from_text "$TOML_LIB_SOURCE_VALUE" "$1" "$2"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_has
# Usage: toml_has PATH
# Description:
#   Test whether a path exists in the current TOML source.
# Output:
#   No stdout output.
# Return:
#   0 if the path exists.
#   Non-zero otherwise.
toml_has() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_has PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_has_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_has_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_each
# Usage: toml_each PATH
# Description:
#   Iterate over an array from the current TOML source.
#   Each element is printed as one compact JSON line.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on missing source, unsupported type, or parse failure.
toml_each() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_each PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_each_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_each_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_len
# Usage: toml_len PATH
# Description:
#   Print the length of a table, array, or string from the current TOML source.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on missing source, unsupported type, or parse failure.
toml_len() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_len PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_len_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_len_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_keys
# Usage: toml_keys PATH
# Description:
#   Print the keys of a table or the indices of an array from the current TOML source.
# Output:
#   Prints one key or index per line.
# Return:
#   0 on success.
#   Non-zero on missing source, unsupported type, or parse failure.
toml_keys() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_keys PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_keys_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_keys_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_type
# Usage: toml_type PATH
# Description:
#   Print the TOML type name at PATH.
#   Possible outputs include string, integer, float, boolean, datetime, date, time, array, and table.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on missing source, missing path, or parse failure.
toml_type() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_type PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_type_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_type_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_true
# Usage: toml_true PATH
# Description:
#   Test whether the value at PATH in the current TOML source is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly true.
#   Non-zero otherwise.
toml_true() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_true PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_true_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_true_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_false
# Usage: toml_false PATH
# Description:
#   Test whether the value at PATH in the current TOML source is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly false.
#   Non-zero otherwise.
toml_false() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_false PATH"
        return 2
    }

    case $TOML_LIB_SOURCE_TYPE in
        file)
            toml_false_from_file "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        text)
            toml_false_from_text "$TOML_LIB_SOURCE_VALUE" "$1"
            ;;
        *)
            _toml_err "no current TOML source, call toml_file or toml_text first"
            return 1
            ;;
    esac
}

# API: toml_query_from_file
# Usage: toml_query_from_file FILE PATH
# Description:
#   Query a specific TOML file using the same path syntax as toml_query.
#   The result is printed as compact JSON.
# Output:
#   Prints the selected value as compact JSON.
# Return:
#   0 on success.
#   Non-zero on invalid path or parse failure.
toml_query_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_query_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=query _toml_run_py
}

# API: toml_query_from_text
# Usage: toml_query_from_text TOML_TEXT PATH
# Description:
#   Query raw TOML text using the same path syntax as toml_query.
#   The result is printed as compact JSON.
# Output:
#   Prints the selected value as compact JSON.
# Return:
#   0 on success.
#   Non-zero on invalid path or parse failure.
toml_query_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_query_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=query _toml_run_py
}

# API: toml_query_from_stdin
# Usage: toml_query_from_stdin PATH
# Description:
#   Query TOML on stdin using the same path syntax as toml_query.
#   The result is printed as compact JSON.
# Output:
#   Prints the selected value as compact JSON.
# Return:
#   0 on success.
#   Non-zero on invalid path or parse failure.
toml_query_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_query_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=query _toml_run_py
}

# API: toml_get_from_file
# Usage: toml_get_from_file FILE PATH
# Description:
#   Read a scalar value from a specific TOML file.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing path, non-scalar result, or parse failure.
toml_get_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_get_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=get _toml_run_py
}

# API: toml_get_from_text
# Usage: toml_get_from_text TOML_TEXT PATH
# Description:
#   Read a scalar value from raw TOML text.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing path, non-scalar result, or parse failure.
toml_get_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_get_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=get _toml_run_py
}

# API: toml_get_from_stdin
# Usage: toml_get_from_stdin PATH
# Description:
#   Read a scalar value from TOML on stdin.
# Output:
#   Prints the scalar value in raw text form.
# Return:
#   0 on success.
#   Non-zero on missing path, non-scalar result, or parse failure.
toml_get_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_get_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=get _toml_run_py
}

# API: toml_getd_from_file
# Usage: toml_getd_from_file FILE PATH DEFAULT_TEXT
# Description:
#   Read a scalar value from a specific TOML file.
#   If the path is missing, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on non-scalar result or parse failure.
toml_getd_from_file() {
    [[ $# -eq 3 ]] || {
        _toml_usage "usage: toml_getd_from_file FILE PATH DEFAULT_TEXT"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_DEFAULT=$3 TOML_LIB_OP=getd _toml_run_py
}

# API: toml_getd_from_text
# Usage: toml_getd_from_text TOML_TEXT PATH DEFAULT_TEXT
# Description:
#   Read a scalar value from raw TOML text.
#   If the path is missing, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on non-scalar result or parse failure.
toml_getd_from_text() {
    [[ $# -eq 3 ]] || {
        _toml_usage "usage: toml_getd_from_text TOML_TEXT PATH DEFAULT_TEXT"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_DEFAULT=$3 TOML_LIB_OP=getd _toml_run_py
}

# API: toml_getd_from_stdin
# Usage: toml_getd_from_stdin PATH DEFAULT_TEXT
# Description:
#   Read a scalar value from TOML on stdin.
#   If the path is missing, print DEFAULT_TEXT instead.
# Output:
#   Prints the scalar value or DEFAULT_TEXT.
# Return:
#   0 on success.
#   Non-zero on non-scalar result or parse failure.
toml_getd_from_stdin() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_getd_from_stdin PATH DEFAULT_TEXT"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_DEFAULT=$2 TOML_LIB_OP=getd _toml_run_py
}

# API: toml_has_from_file
# Usage: toml_has_from_file FILE PATH
# Description:
#   Test whether a path exists in a specific TOML file.
# Output:
#   No stdout output.
# Return:
#   0 if the path exists.
#   Non-zero otherwise.
toml_has_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_has_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=has _toml_run_py >/dev/null
}

# API: toml_has_from_text
# Usage: toml_has_from_text TOML_TEXT PATH
# Description:
#   Test whether a path exists in raw TOML text.
# Output:
#   No stdout output.
# Return:
#   0 if the path exists.
#   Non-zero otherwise.
toml_has_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_has_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=has _toml_run_py >/dev/null
}

# API: toml_has_from_stdin
# Usage: toml_has_from_stdin PATH
# Description:
#   Test whether a path exists in TOML on stdin.
# Output:
#   No stdout output.
# Return:
#   0 if the path exists.
#   Non-zero otherwise.
toml_has_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_has_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=has _toml_run_py >/dev/null
}

# API: toml_each_from_file
# Usage: toml_each_from_file FILE PATH
# Description:
#   Iterate over an array from a specific TOML file.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_each_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_each_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=each _toml_run_py
}

# API: toml_each_from_text
# Usage: toml_each_from_text TOML_TEXT PATH
# Description:
#   Iterate over an array from raw TOML text.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_each_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_each_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=each _toml_run_py
}

# API: toml_each_from_stdin
# Usage: toml_each_from_stdin PATH
# Description:
#   Iterate over an array from TOML on stdin.
# Output:
#   Prints one compact JSON value per line.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_each_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_each_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=each _toml_run_py
}

# API: toml_len_from_file
# Usage: toml_len_from_file FILE PATH
# Description:
#   Print the length of a table, array, or string from a specific TOML file.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_len_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_len_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=len _toml_run_py
}

# API: toml_len_from_text
# Usage: toml_len_from_text TOML_TEXT PATH
# Description:
#   Print the length of a table, array, or string from raw TOML text.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_len_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_len_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=len _toml_run_py
}

# API: toml_len_from_stdin
# Usage: toml_len_from_stdin PATH
# Description:
#   Print the length of a table, array, or string from TOML on stdin.
# Output:
#   Prints a numeric length.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_len_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_len_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=len _toml_run_py
}

# API: toml_keys_from_file
# Usage: toml_keys_from_file FILE PATH
# Description:
#   Print the keys of a table or the indices of an array from a specific TOML file.
# Output:
#   Prints one key or index per line.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_keys_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_keys_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=keys _toml_run_py
}

# API: toml_keys_from_text
# Usage: toml_keys_from_text TOML_TEXT PATH
# Description:
#   Print the keys of a table or the indices of an array from raw TOML text.
# Output:
#   Prints one key or index per line.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_keys_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_keys_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=keys _toml_run_py
}

# API: toml_keys_from_stdin
# Usage: toml_keys_from_stdin PATH
# Description:
#   Print the keys of a table or the indices of an array from TOML on stdin.
# Output:
#   Prints one key or index per line.
# Return:
#   0 on success.
#   Non-zero on missing path, unsupported type, or parse failure.
toml_keys_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_keys_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=keys _toml_run_py
}

# API: toml_type_from_file
# Usage: toml_type_from_file FILE PATH
# Description:
#   Print the TOML type name at PATH from a specific TOML file.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on missing path or parse failure.
toml_type_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_type_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=type _toml_run_py
}

# API: toml_type_from_text
# Usage: toml_type_from_text TOML_TEXT PATH
# Description:
#   Print the TOML type name at PATH from raw TOML text.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on missing path or parse failure.
toml_type_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_type_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=type _toml_run_py
}

# API: toml_type_from_stdin
# Usage: toml_type_from_stdin PATH
# Description:
#   Print the TOML type name at PATH from TOML on stdin.
# Output:
#   Prints the type name as text.
# Return:
#   0 on success.
#   Non-zero on missing path or parse failure.
toml_type_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_type_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=type _toml_run_py
}

# API: toml_true_from_file
# Usage: toml_true_from_file FILE PATH
# Description:
#   Test whether the value at PATH in a specific TOML file is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly true.
#   Non-zero otherwise.
toml_true_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_true_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=true _toml_run_py >/dev/null
}

# API: toml_true_from_text
# Usage: toml_true_from_text TOML_TEXT PATH
# Description:
#   Test whether the value at PATH in raw TOML text is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly true.
#   Non-zero otherwise.
toml_true_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_true_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=true _toml_run_py >/dev/null
}

# API: toml_true_from_stdin
# Usage: toml_true_from_stdin PATH
# Description:
#   Test whether the value at PATH in TOML on stdin is exactly true.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly true.
#   Non-zero otherwise.
toml_true_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_true_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=true _toml_run_py >/dev/null
}

# API: toml_false_from_file
# Usage: toml_false_from_file FILE PATH
# Description:
#   Test whether the value at PATH in a specific TOML file is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly false.
#   Non-zero otherwise.
toml_false_from_file() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_false_from_file FILE PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=file TOML_LIB_FILE=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=false _toml_run_py >/dev/null
}

# API: toml_false_from_text
# Usage: toml_false_from_text TOML_TEXT PATH
# Description:
#   Test whether the value at PATH in raw TOML text is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly false.
#   Non-zero otherwise.
toml_false_from_text() {
    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_false_from_text TOML_TEXT PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_PATH=$2 TOML_LIB_OP=false _toml_run_py >/dev/null
}

# API: toml_false_from_stdin
# Usage: toml_false_from_stdin PATH
# Description:
#   Test whether the value at PATH in TOML on stdin is exactly false.
# Output:
#   No stdout output.
# Return:
#   0 if the value is exactly false.
#   Non-zero otherwise.
toml_false_from_stdin() {
    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_false_from_stdin PATH"
        return 2
    }

    toml_require_read || return $?
    TOML_LIB_SOURCE=stdin TOML_LIB_PATH=$1 TOML_LIB_OP=false _toml_run_py >/dev/null
}

# API: toml_begin_file
# Usage: toml_begin_file FILE
# Description:
#   Start a builder session backed by FILE.
#   If FILE exists and is valid TOML, it is loaded into a plain JSON-like builder tree.
#   If FILE does not exist or is empty, a new empty table is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on parse failure or builder setup failure.
toml_begin_file() {
    local target_file
    local state_file

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_begin_file FILE"
        return 2
    }

    target_file=$1

    toml_require_read || return $?
    toml_require_jq || return $?

    state_file=$(_toml_mktemp_state) || return 1

    if [[ -f $target_file && -s $target_file ]]; then
        if ! TOML_LIB_SOURCE=file TOML_LIB_FILE=$target_file TOML_LIB_OP=load_as_json _toml_run_py > "$state_file"; then
            rm -f -- "$state_file"
            return 1
        fi
    else
        printf '{}\n' > "$state_file"
    fi

    _toml_cleanup_builder
    TOML_LIB_BUILD_FILE=$target_file
    TOML_LIB_BUILD_STATE=$state_file
    TOML_LIB_BUILD_PATHS=('[]')

    TOML_LIB_SOURCE_TYPE="file"
    TOML_LIB_SOURCE_VALUE=$target_file
}

# API: toml_begin_text
# Usage: toml_begin_text TOML_TEXT
# Description:
#   Start a builder session from raw TOML text.
#   This session has no output file until toml_save FILE is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on parse failure or builder setup failure.
toml_begin_text() {
    local state_file

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_begin_text TOML_TEXT"
        return 2
    }

    toml_require_read || return $?
    toml_require_jq || return $?

    state_file=$(_toml_mktemp_state) || return 1
    if ! TOML_LIB_SOURCE=text TOML_LIB_TEXT=$1 TOML_LIB_OP=load_as_json _toml_run_py > "$state_file"; then
        rm -f -- "$state_file"
        return 1
    fi

    _toml_cleanup_builder
    TOML_LIB_BUILD_STATE=$state_file
    TOML_LIB_BUILD_PATHS=('[]')

    TOML_LIB_SOURCE_TYPE="text"
    TOML_LIB_SOURCE_VALUE=$1
}

# API: toml_reset
# Usage: toml_reset
# Description:
#   Reset the active builder session to an empty root table.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on missing builder session.
toml_reset() {
    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_reset"
        return 2
    }

    [[ -n ${TOML_LIB_BUILD_STATE:-} ]] || {
        _toml_err "no active TOML builder session"
        return 1
    }

    printf '{}\n' > "$TOML_LIB_BUILD_STATE"
    TOML_LIB_BUILD_PATHS=('[]')
}

# API: toml_print
# Usage: toml_print
# Description:
#   Print the current builder document as TOML.
# Output:
#   Prints the current builder TOML document.
# Return:
#   0 on success.
#   Non-zero on missing builder session or serializer failure.
toml_print() {
    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_print"
        return 2
    }

    [[ -n ${TOML_LIB_BUILD_STATE:-} && -f ${TOML_LIB_BUILD_STATE:-} ]] || {
        _toml_err "no active TOML builder session"
        return 1
    }

    TOML_LIB_STATE_FILE=$TOML_LIB_BUILD_STATE TOML_LIB_OP=save_from_json _toml_run_py
}

# API: toml_save
# Usage: toml_save [FILE]
# Description:
#   Save the current builder document to FILE.
#   If FILE is omitted, the file passed to toml_begin_file is used.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on missing builder session or save failure.
toml_save() {
    local target_file=${1:-$TOML_LIB_BUILD_FILE}
    local tmp_file

    [[ $# -le 1 ]] || {
        _toml_usage "usage: toml_save [FILE]"
        return 2
    }

    [[ -n ${TOML_LIB_BUILD_STATE:-} && -f ${TOML_LIB_BUILD_STATE:-} ]] || {
        _toml_err "no active TOML builder session"
        return 1
    }

    [[ -n $target_file ]] || {
        _toml_err "no target file, call toml_save FILE or start with toml_begin_file"
        return 1
    }

    tmp_file=$(_toml_mktemp_for "$target_file") || return 1
    if ! TOML_LIB_STATE_FILE=$TOML_LIB_BUILD_STATE TOML_LIB_OP=save_from_json _toml_run_py > "$tmp_file"; then
        rm -f -- "$tmp_file"
        return 1
    fi

    _toml_move_into_place "$tmp_file" "$target_file"
    TOML_LIB_BUILD_FILE=$target_file
    TOML_LIB_SOURCE_TYPE="file"
    TOML_LIB_SOURCE_VALUE=$target_file
}

# API: toml_close
# Usage: toml_close
# Description:
#   Leave the current nested container and return to its parent.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if already at root or no builder session is active.
toml_close() {
    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_close"
        return 2
    }

    _toml_pop_path_json
}

# API: toml_new_object
# Usage: toml_new_object KEY
# Description:
#   Create a new empty table under the current table and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not a table/object or no builder session is active.
toml_new_object() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_new_object KEY"
        return 2
    }

    _toml_require_type object || return 1
    path_json=$(_toml_current_path_json) || return 1
    child_path=$(_toml_path_append_key "$path_json" "$1") || return 1

    _toml_apply 'setpath($path; {})' --argjson path "$child_path" || return 1
    _toml_push_path_json "$child_path"
}

# API: toml_new_array
# Usage: toml_new_array KEY
# Description:
#   Create a new empty array under the current table and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero if the current container is not a table/object or no builder session is active.
toml_new_array() {
    local path_json
    local child_path

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_new_array KEY"
        return 2
    }

    _toml_require_type object || return 1
    path_json=$(_toml_current_path_json) || return 1
    child_path=$(_toml_path_append_key "$path_json" "$1") || return 1

    _toml_apply 'setpath($path; [])' --argjson path "$child_path" || return 1
    _toml_push_path_json "$child_path"
}

# API: toml_add_string
# Usage: toml_add_string KEY VALUE
# Description:
#   Add a string field to the current table/object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
toml_add_string() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_add_string KEY VALUE"
        return 2
    }

    _toml_require_type object || return 1
    path_json=$(_toml_current_path_json) || return 1
    child_path=$(_toml_path_append_key "$path_json" "$1") || return 1

    _toml_apply 'setpath($path; $value)' --argjson path "$child_path" --arg value "$2"
}

# API: toml_add_int
# Usage: toml_add_int KEY VALUE
# Description:
#   Add an integer field to the current table/object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid integer, wrong container type, or missing builder session.
toml_add_int() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_add_int KEY VALUE"
        return 2
    }

    _toml_validate_int "$2" || return 1
    _toml_require_type object || return 1
    path_json=$(_toml_current_path_json) || return 1
    child_path=$(_toml_path_append_key "$path_json" "$1") || return 1

    _toml_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: toml_add_float
# Usage: toml_add_float KEY VALUE
# Description:
#   Add a floating-point field to the current table/object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid float, wrong container type, or missing builder session.
toml_add_float() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_add_float KEY VALUE"
        return 2
    }

    _toml_validate_float "$2" || return 1
    _toml_require_type object || return 1
    path_json=$(_toml_current_path_json) || return 1
    child_path=$(_toml_path_append_key "$path_json" "$1") || return 1

    _toml_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: toml_add_bool
# Usage: toml_add_bool KEY {true|false}
# Description:
#   Add a boolean field to the current table/object container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid boolean, wrong container type, or missing builder session.
toml_add_bool() {
    local path_json
    local child_path

    [[ $# -eq 2 ]] || {
        _toml_usage "usage: toml_add_bool KEY {true|false}"
        return 2
    }

    _toml_validate_bool "$2" || return 1
    _toml_require_type object || return 1
    path_json=$(_toml_current_path_json) || return 1
    child_path=$(_toml_path_append_key "$path_json" "$1") || return 1

    _toml_apply 'setpath($path; $value)' --argjson path "$child_path" --argjson value "$2"
}

# API: toml_push_object
# Usage: toml_push_object
# Description:
#   Append a new empty table to the current array container and enter it.
#   When the array contains only objects, it will serialize as an array of tables.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
toml_push_object() {
    local path_json
    local index
    local child_path

    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_push_object"
        return 2
    }

    _toml_require_type array || return 1
    path_json=$(_toml_current_path_json) || return 1
    index=$(_toml_current_length) || return 1
    _toml_apply 'setpath($path; (getpath($path) + [{}]))' --argjson path "$path_json" || return 1
    child_path=$(_toml_path_append_index "$path_json" "$index") || return 1
    _toml_push_path_json "$child_path"
}

# API: toml_push_array
# Usage: toml_push_array
# Description:
#   Append a new empty array to the current array container and enter it.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
toml_push_array() {
    local path_json
    local index
    local child_path

    [[ $# -eq 0 ]] || {
        _toml_usage "usage: toml_push_array"
        return 2
    }

    _toml_require_type array || return 1
    path_json=$(_toml_current_path_json) || return 1
    index=$(_toml_current_length) || return 1
    _toml_apply 'setpath($path; (getpath($path) + [[]]))' --argjson path "$path_json" || return 1
    child_path=$(_toml_path_append_index "$path_json" "$index") || return 1
    _toml_push_path_json "$child_path"
}

# API: toml_push_string
# Usage: toml_push_string VALUE
# Description:
#   Append a string value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on wrong container type or missing builder session.
toml_push_string() {
    local path_json

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_push_string VALUE"
        return 2
    }

    _toml_require_type array || return 1
    path_json=$(_toml_current_path_json) || return 1
    _toml_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --arg value "$1"
}

# API: toml_push_int
# Usage: toml_push_int VALUE
# Description:
#   Append an integer value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid integer, wrong container type, or missing builder session.
toml_push_int() {
    local path_json

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_push_int VALUE"
        return 2
    }

    _toml_validate_int "$1" || return 1
    _toml_require_type array || return 1
    path_json=$(_toml_current_path_json) || return 1
    _toml_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: toml_push_float
# Usage: toml_push_float VALUE
# Description:
#   Append a floating-point value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid float, wrong container type, or missing builder session.
toml_push_float() {
    local path_json

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_push_float VALUE"
        return 2
    }

    _toml_validate_float "$1" || return 1
    _toml_require_type array || return 1
    path_json=$(_toml_current_path_json) || return 1
    _toml_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}

# API: toml_push_bool
# Usage: toml_push_bool {true|false}
# Description:
#   Append a boolean value to the current array container.
# Output:
#   No stdout output.
# Return:
#   0 on success.
#   Non-zero on invalid boolean, wrong container type, or missing builder session.
toml_push_bool() {
    local path_json

    [[ $# -eq 1 ]] || {
        _toml_usage "usage: toml_push_bool {true|false}"
        return 2
    }

    _toml_validate_bool "$1" || return 1
    _toml_require_type array || return 1
    path_json=$(_toml_current_path_json) || return 1
    _toml_apply 'setpath($path; (getpath($path) + [$value]))' --argjson path "$path_json" --argjson value "$1"
}
