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

command -v yq >/dev/null 2>&1 || skip 'yq not found'
command -v jq >/dev/null 2>&1 || skip 'jq not found'
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../lib/yaml.bash"

work_dir=$(mktemp -d)
trap 'echo "test.yaml:"; cat $yaml_file_path; rm -rf -- "$work_dir"' EXIT
yaml_file_path="$work_dir/test.yaml"

yaml_begin_file "$yaml_file_path" || fail 'yaml_begin_file failed'
yaml_reset object || fail 'yaml_reset failed'
yaml_add_string name demo || fail 'yaml_add_string failed'
yaml_add_int version 3 || fail 'yaml_add_int failed'
yaml_add_bool enabled true || fail 'yaml_add_bool failed'
yaml_add_null deleted_at || fail 'yaml_add_null failed'
yaml_new_object server || fail 'yaml_new_object failed'
yaml_add_string host 127.0.0.1 || fail 'yaml_add_string in object failed'
yaml_add_int port 8080 || fail 'yaml_add_int in object failed'
yaml_close || fail 'yaml_close after object failed'
yaml_new_array ports || fail 'yaml_new_array failed'
yaml_push_int 8000 || fail 'yaml_push_int failed'
yaml_push_int 8001 || fail 'yaml_push_int failed'
yaml_push_object || fail 'yaml_push_object failed'
yaml_add_string role api || fail 'yaml_add_string in pushed object failed'
yaml_add_bool tls false || fail 'yaml_add_bool in pushed object failed'
yaml_close || fail 'yaml_close after pushed object failed'
yaml_push_array || fail 'yaml_push_array failed'
yaml_push_string nested || fail 'yaml_push_string in nested array failed'
yaml_push_null || fail 'yaml_push_null failed'
yaml_close || fail 'yaml_close after pushed array failed'
yaml_close || fail 'yaml_close after ports array failed'
yaml_save || fail 'yaml_save failed'

yaml_validate_file "$yaml_file_path" || fail 'yaml_validate_file failed'
name=$(yaml_get_from_file "$yaml_file_path" '.name') || fail 'yaml_get_from_file failed'
assert_eq "$name" 'demo' 'yaml_get_from_file returned wrong value'
default_value=$(yaml_getd_from_file "$yaml_file_path" '.missing' 'fallback') || fail 'yaml_getd_from_file failed'
assert_eq "$default_value" 'fallback' 'yaml_getd_from_file returned wrong default'
yaml_has_from_file "$yaml_file_path" '.server.port' || fail 'yaml_has_from_file should succeed'
if yaml_has_from_file "$yaml_file_path" '.missing'; then fail 'yaml_has_from_file should fail on missing path'; fi
len=$(yaml_len_from_file "$yaml_file_path" '.ports') || fail 'yaml_len_from_file failed'
assert_eq "$len" '4' 'yaml_len_from_file returned wrong length'
type_name=$(yaml_type_from_file "$yaml_file_path" '.server') || fail 'yaml_type_from_file failed'
assert_eq "$type_name" '!!map' 'yaml_type_from_file returned wrong type'
yaml_true_from_file "$yaml_file_path" '.enabled' || fail 'yaml_true_from_file should succeed'
yaml_false_from_file "$yaml_file_path" '.ports[2].tls' || fail 'yaml_false_from_file should succeed'
keys_output=$(yaml_keys_from_file "$yaml_file_path" '.server' | sort | tr '\n' ' ' | sed 's/ $//') || fail 'yaml_keys_from_file failed'
assert_eq "$keys_output" 'host port' 'yaml_keys_from_file returned wrong keys'
each_output=$(yaml_each_from_file "$yaml_file_path" '.ports' | wc -l | tr -d ' ') || fail 'yaml_each_from_file failed'
assert_eq "$each_output" '4' 'yaml_each_from_file returned wrong count'
yaml_file "$yaml_file_path" || fail 'yaml_file failed'
current_name=$(yaml_get '.name') || fail 'yaml_get on current source failed'
assert_eq "$current_name" 'demo' 'yaml_get on current source returned wrong value'

printf 'TEST: yaml_getd preserves false and only defaults null/missing values\n'
false_value=$(yaml_getd_from_text $'answer: false\nmissing: null\n' '.answer' fallback) || fail 'yaml_getd false read failed'
assert_eq "$false_value" 'false' 'yaml_getd should preserve false'
null_default=$(yaml_getd_from_text $'answer: false\nmissing: null\n' '.missing' fallback) || fail 'yaml_getd null default failed'
assert_eq "$null_default" 'fallback' 'yaml_getd should default null'

printf 'TEST: yaml builder rejects multi-document input\n'
if yaml_begin_text $'---\nfirst: 1\n---\nsecond: 2\n' >/dev/null 2>&1; then
    fail 'yaml_begin_text should reject multiple documents'
fi

printf 'TEST: yaml_begin_file reports usage under set -u\n'
if (set -u; yaml_begin_file >/dev/null 2>&1); then
    fail 'yaml_begin_file without FILE should fail'
else
    rc=$?
    assert_eq "$rc" '2' 'yaml_begin_file should return usage status 2'
fi

pass "$0"
