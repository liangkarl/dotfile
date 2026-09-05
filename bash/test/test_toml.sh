#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'RESULT: PASS: %s\n' "$*"; }
skip() { printf 'SKIP: %s\n' "$*"; exit 77; }
assert_eq() {
    local actual=$1 expected=$2 message=$3
    [[ "$actual" == "$expected" ]] || { printf 'Expected: [%s]\nActual:   [%s]\n' "$expected" "$actual" >&2; fail "$message"; }
}

command -v python3 >/dev/null 2>&1 || skip 'python3 not found'
python3 - <<'PY' >/dev/null 2>&1 || skip 'tomllib/tomlkit not available'
import tomllib
import tomlkit
PY
command -v jq >/dev/null 2>&1 || skip 'jq not found'
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../lib/toml.bash"

work_dir=$(mktemp -d)
trap 'echo "test.toml:"; cat "$toml_file_path"; rm -rf -- "$work_dir"' EXIT
toml_file_path="$work_dir/test.toml"

toml_begin_file "$toml_file_path" || fail 'toml_begin_file failed'
toml_reset || fail 'toml_reset failed'
toml_add_string name demo || fail 'toml_add_string failed'
toml_add_int version 3 || fail 'toml_add_int failed'
toml_add_bool enabled true || fail 'toml_add_bool failed'
toml_new_object server || fail 'toml_new_object failed'
toml_add_string host 127.0.0.1 || fail 'toml_add_string in object failed'
toml_add_int port 8080 || fail 'toml_add_int in object failed'
toml_close || fail 'toml_close after object failed'
toml_new_array ports || fail 'toml_new_array failed'
toml_push_int 8000 || fail 'toml_push_int failed'
toml_push_int 8001 || fail 'toml_push_int failed'
toml_push_object || fail 'toml_push_object failed'
toml_add_string role api || fail 'toml_add_string in pushed object failed'
toml_add_bool tls false || fail 'toml_add_bool in pushed object failed'
toml_close || fail 'toml_close after pushed object failed'
toml_push_array || fail 'toml_push_array failed'
toml_push_string nested || fail 'toml_push_string in nested array failed'
toml_close || fail 'toml_close after pushed array failed'
toml_close || fail 'toml_close after ports array failed'
toml_save || fail 'toml_save failed'

toml_validate_file "$toml_file_path" || fail 'toml_validate_file failed'
name=$(toml_get_from_file "$toml_file_path" '.name') || fail 'toml_get_from_file failed'
assert_eq "$name" 'demo' 'toml_get_from_file returned wrong value'
default_value=$(toml_getd_from_file "$toml_file_path" '.missing' 'fallback') || fail 'toml_getd_from_file failed'
assert_eq "$default_value" 'fallback' 'toml_getd_from_file returned wrong default'
toml_has_from_file "$toml_file_path" '.server.port' || fail 'toml_has_from_file should succeed'
if toml_has_from_file "$toml_file_path" '.missing'; then fail 'toml_has_from_file should fail on missing path'; fi
len=$(toml_len_from_file "$toml_file_path" '.ports') || fail 'toml_len_from_file failed'
assert_eq "$len" '4' 'toml_len_from_file returned wrong length'
type_name=$(toml_type_from_file "$toml_file_path" '.server') || fail 'toml_type_from_file failed'
assert_eq "$type_name" 'table' 'toml_type_from_file returned wrong type'
toml_true_from_file "$toml_file_path" '.enabled' || fail 'toml_true_from_file should succeed'
toml_false_from_file "$toml_file_path" '.ports[2].tls' || fail 'toml_false_from_file should succeed'
keys_output=$(toml_keys_from_file "$toml_file_path" '.server' | sort | tr '\n' ' ' | sed 's/ $//') || fail 'toml_keys_from_file failed'
assert_eq "$keys_output" 'host port' 'toml_keys_from_file returned wrong keys'
each_output=$(toml_each_from_file "$toml_file_path" '.ports' | wc -l | tr -d ' ') || fail 'toml_each_from_file failed'
assert_eq "$each_output" '4' 'toml_each_from_file returned wrong count'
toml_file "$toml_file_path" || fail 'toml_file failed'
current_name=$(toml_get '.name') || fail 'toml_get on current source failed'
assert_eq "$current_name" 'demo' 'toml_get on current source returned wrong value'

printf 'TEST: toml path parser supports quoted keys\n'
quoted_key_value=$(toml_get_from_text $'["tool.poetry"]\nversion = "1.2.3"\n' '.["tool.poetry"].version') || fail 'toml quoted-key lookup failed'
assert_eq "$quoted_key_value" '1.2.3' 'toml quoted-key lookup returned wrong value'

printf 'TEST: toml_begin_file reports usage under set -u\n'
if (set -u; toml_begin_file >/dev/null 2>&1); then
    fail 'toml_begin_file without FILE should fail'
else
    rc=$?
    assert_eq "$rc" '2' 'toml_begin_file should return usage status 2'
fi

pass "$0"
