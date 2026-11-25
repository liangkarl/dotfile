#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BASH_CFG=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
source "$SCRIPT_DIR/../../bin/bash-env"
load debug

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT

cat > "$work_dir/other file.sh" <<'SCRIPT'
other_message() { msg.dbg "$1"; }
other_command() { dbg.cmd 'printf "command output\\n"'; }
SCRIPT
source "$work_dir/other file.sh"

space=$(dbg.space)
[[ $space == test_debug.sh ]] || fail 'dbg.space did not return the caller basename'
dbg.on "$space"
{
    msg.dbg 'enabled 100%'
    other_message 'hidden'
    dbg.on 'other file.sh'
    other_message 'visible'
    other_command
    dbg.off "$space"
    msg.dbg 'hidden too'
    other_message 'still visible'
    dbg.off 'other file.sh'
    dbg.on
    other_message 'global'
    dbg.off
    other_message 'hidden after global off'
} > "$work_dir/output"
printf '%s\n' 'DEBUG: test_debug.sh: enabled 100%' 'DEBUG: other file.sh: visible' 'DEBUG: other file.sh: printf "command output\\n"' 'command output' 'DEBUG: other file.sh: still visible' 'DEBUG: other file.sh: global' > "$work_dir/expected"
cmp -s "$work_dir/output" "$work_dir/expected" || { diff -u "$work_dir/expected" "$work_dir/output"; fail 'space selection or command attribution'; }

dbg.file "$work_dir/debug log"
dbg.on
{
    msg.dbg 'logged'
    printf 'ordinary stdout\n'
    printf 'ordinary stderr\n' >&2
    dbg.off
    msg.dbg 'not logged'
    dbg.on
    dbg.file
    msg.dbg 'file disabled'
} > "$work_dir/stdout" 2> "$work_dir/stderr"
printf '%s\n' 'DEBUG: test_debug.sh: logged' > "$work_dir/expected"
cmp -s "$work_dir/debug log" "$work_dir/expected" || fail 'debug file contains unexpected output'
printf '%s\n' 'DEBUG: test_debug.sh: logged' 'ordinary stdout' 'DEBUG: test_debug.sh: file disabled' > "$work_dir/expected"
cmp -s "$work_dir/stdout" "$work_dir/expected" || fail 'stdout changed by file logging'
[[ $(cat "$work_dir/stderr") == 'ordinary stderr' ]] || fail 'stderr changed by file logging'
unload debug
! declare -F msg.dbg >/dev/null || fail 'unload debug left functions behind'
printf 'RESULT: PASS: %s\n' "$0"
