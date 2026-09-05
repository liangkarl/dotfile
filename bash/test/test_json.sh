#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'RESULT: PASS: %s\n' "$*"; }
skip() { printf 'SKIP: %s\n' "$*"; exit 77; }

assert_eq() {
    local actual=$1
    local expected=$2
    local message=$3
    [[ "$actual" == "$expected" ]] || { printf 'Expected: [%s]\nActual:   [%s]\n' "$expected" "$actual" >&2; fail "$message"; }
}

assert_file_json_eq() {
    local file=$1 jq_filter=$2 expected=$3 actual
    actual=$(jq -c "$jq_filter" "$file") || fail "jq check failed: $jq_filter"
    assert_eq "$actual" "$expected" "JSON assertion failed for $jq_filter"
}

command -v jq >/dev/null 2>&1 || skip 'jq not found'
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../lib/json.bash"

work_dir=$(mktemp -d)
trap 'echo "test.json:"; cat "$json_file_path"; rm -rf -- "$work_dir"' EXIT
json_file_path="$work_dir/test.json"

json_begin_file "$json_file_path" || fail 'json_begin_file failed'
json_reset object || fail 'json_reset failed'
json_add_string name demo || fail 'json_add_string failed'
json_add_int version 3 || fail 'json_add_int failed'
json_add_bool enabled true || fail 'json_add_bool failed'
json_add_null deleted_at || fail 'json_add_null failed'
json_new_object server || fail 'json_new_object failed'
json_add_string host 127.0.0.1 || fail 'json_add_string in object failed'
json_add_int port 8080 || fail 'json_add_int in object failed'
json_close || fail 'json_close after object failed'
json_new_array ports || fail 'json_new_array failed'
json_push_int 8000 || fail 'json_push_int failed'
json_push_int 8001 || fail 'json_push_int failed'
json_push_object || fail 'json_push_object failed'
json_add_string role api || fail 'json_add_string in pushed object failed'
json_add_bool tls false || fail 'json_add_bool in pushed object failed'
json_close || fail 'json_close after pushed object failed'
json_push_array || fail 'json_push_array failed'
json_push_string nested || fail 'json_push_string in nested array failed'
json_push_null || fail 'json_push_null failed'
json_close || fail 'json_close after pushed array failed'
json_close || fail 'json_close after ports array failed'
json_save || fail 'json_save failed'

json_validate_file "$json_file_path" || fail 'json_validate_file failed'
assert_file_json_eq "$json_file_path" '.name' '"demo"'
assert_file_json_eq "$json_file_path" '.version' '3'
assert_file_json_eq "$json_file_path" '.enabled' 'true'
assert_file_json_eq "$json_file_path" '.deleted_at' 'null'
assert_file_json_eq "$json_file_path" '.server.host' '"127.0.0.1"'
assert_file_json_eq "$json_file_path" '.server.port' '8080'
assert_file_json_eq "$json_file_path" '.ports | length' '4'
assert_file_json_eq "$json_file_path" '.ports[2].role' '"api"'
assert_file_json_eq "$json_file_path" '.ports[2].tls' 'false'
assert_file_json_eq "$json_file_path" '.ports[3][0]' '"nested"'
assert_file_json_eq "$json_file_path" '.ports[3][1]' 'null'

name=$(json_get_from_file "$json_file_path" '.name') || fail 'json_get_from_file failed'
assert_eq "$name" 'demo' 'json_get_from_file returned wrong value'
default_value=$(json_getd_from_file "$json_file_path" '.missing' 'fallback') || fail 'json_getd_from_file failed'
assert_eq "$default_value" 'fallback' 'json_getd_from_file returned wrong default'
json_has_from_file "$json_file_path" '.server.port' || fail 'json_has_from_file should succeed'
if json_has_from_file "$json_file_path" '.missing'; then fail 'json_has_from_file should fail on missing path'; fi
len=$(json_len_from_file "$json_file_path" '.ports') || fail 'json_len_from_file failed'
assert_eq "$len" '4' 'json_len_from_file returned wrong length'
type_name=$(json_type_from_file "$json_file_path" '.server') || fail 'json_type_from_file failed'
assert_eq "$type_name" 'object' 'json_type_from_file returned wrong type'
json_true_from_file "$json_file_path" '.enabled' || fail 'json_true_from_file should succeed'
json_false_from_file "$json_file_path" '.ports[2].tls' || fail 'json_false_from_file should succeed'
keys_output=$(json_keys_from_file "$json_file_path" '.server' | sort | tr '\n' ' ' | sed 's/ $//') || fail 'json_keys_from_file failed'
assert_eq "$keys_output" 'host port' 'json_keys_from_file returned wrong keys'
each_output=$(json_each_from_file "$json_file_path" '.ports' | wc -l | tr -d ' ') || fail 'json_each_from_file failed'
assert_eq "$each_output" '4' 'json_each_from_file returned wrong count'
json_file "$json_file_path" || fail 'json_file failed'
current_name=$(json_get '.name') || fail 'json_get on current source failed'
assert_eq "$current_name" 'demo' 'json_get on current source returned wrong value'

printf 'TEST: json_getd preserves false and only defaults null/missing values\n'
false_value=$(json_getd_from_text '{"answer":false,"missing":null}' '.answer' fallback) || fail 'json_getd false read failed'
assert_eq "$false_value" 'false' 'json_getd should preserve false'
null_default=$(json_getd_from_text '{"answer":false,"missing":null}' '.missing' fallback) || fail 'json_getd null default failed'
assert_eq "$null_default" 'fallback' 'json_getd should default null'

printf 'TEST: json_begin_file reports usage under set -u\n'
if (set -u; json_begin_file >/dev/null 2>&1); then
    fail 'json_begin_file without FILE should fail'
else
    rc=$?
    assert_eq "$rc" '2' 'json_begin_file should return usage status 2'
fi

pass "$0"
