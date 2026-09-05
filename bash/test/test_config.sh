#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB_FILE="$SCRIPT_DIR/../lib/config.bash"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'RESULT: PASS: %s\n' "$*"; }
assert_eq() {
    local actual=$1 expected=$2 message=$3
    [[ "$actual" == "$expected" ]] || {
        printf 'Expected: [%s]\nActual:   [%s]\n' "$expected" "$actual" >&2
        fail "$message"
    }
}

sys.stage_start() { :; }
sys.stage_stop() { :; }
lib.load() { :; }
dbg.mark() { :; }
msg.dbg() { :; }

# shellcheck source=/dev/null
source "$LIB_FILE"

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
config_file="$work_dir/config with spaces"

printf 'TEST: config safely round-trips empty, quoted, escaped, and multiline values\n'
config.load "$config_file" || fail 'config.load failed'
config.set empty '' || fail 'config.set empty failed'
config.set author "O'Reilly" || fail 'config.set quoted value failed'
config.set path 'C:\tools' || fail 'config.set backslash value failed'
config.set multiline $'first\nsecond' || fail 'config.set multiline value failed'
config.save || fail 'config.save failed'
config.load "$config_file" || fail 'config.reload failed'
config.get empty_value empty fallback || fail 'config.get empty failed'
config.get author_value author || fail 'config.get author failed'
config.get path_value path || fail 'config.get path failed'
config.get multiline_value multiline || fail 'config.get multiline failed'
assert_eq "$empty_value" '' 'empty value was not preserved'
assert_eq "$author_value" "O'Reilly" 'quoted value was not preserved'
assert_eq "$path_value" 'C:\tools' 'backslash value was not preserved'
assert_eq "$multiline_value" $'first\nsecond' 'multiline value was not preserved'

printf 'TEST: config reset removes empty cached values\n'
config.reset
if [[ -v __CONFIG_CONFIG_WITH_SPACES_empty ]]; then
    fail 'config.reset retained an empty cached value'
fi

printf 'TEST: config treats configuration content as data, not shell code\n'
marker_file="$work_dir/marker"
untrusted_file="$work_dir/untrusted"
printf '%s\n' "value='literal; touch $marker_file'" > "$untrusted_file"
config.load "$untrusted_file" || fail 'config.load untrusted data failed'
config.get literal_value value || fail 'config.get untrusted data failed'
assert_eq "$literal_value" "literal; touch $marker_file" 'untrusted value was parsed incorrectly'
[[ ! -e $marker_file ]] || fail 'configuration content was executed'

printf 'TEST: config supports legacy plain and single-quoted assignments\n'
legacy_file="$work_dir/legacy"
printf "plain=value\nlegacy='legacy value'\n" > "$legacy_file"
config.load "$legacy_file" || fail 'config.load legacy file failed'
config.get plain_value plain || fail 'config.get plain value failed'
config.get legacy_value legacy || fail 'config.get quoted value failed'
assert_eq "$plain_value" 'value' 'plain legacy value was not preserved'
assert_eq "$legacy_value" 'legacy value' 'quoted legacy value was not preserved'

printf 'TEST: config rejects malformed input and validates usage under set -u\n'
invalid_file="$work_dir/invalid"
printf 'not an assignment\n' > "$invalid_file"
if config.load "$invalid_file" >/dev/null 2>&1; then
    fail 'config.load should reject malformed input'
fi
if (set -u; config.load >/dev/null 2>&1); then
    fail 'config.load without FILE should fail'
else
    rc=$?
    assert_eq "$rc" '2' 'config.load should return usage status 2'
fi

pass "$0"
