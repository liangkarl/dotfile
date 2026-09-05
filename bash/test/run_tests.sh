#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
test_files=(
    "$SCRIPT_DIR/test_json.sh"
    "$SCRIPT_DIR/test_toml.sh"
    "$SCRIPT_DIR/test_yaml.sh"
    "$SCRIPT_DIR/test_config.sh"
)

status=0
for test_file in "${test_files[@]}"; do
    printf 'SYNTAX: LC_ALL=C LANG=C bash %q\n' "$test_file"
    if LC_ALL=C LANG=C bash "$test_file"; then
        printf 'RESULT: PASS: %s\n' "$test_file"
    else
        rc=$?
        if [[ $rc -eq 77 ]]; then
            printf 'RESULT: SKIP: %s\n' "$test_file"
        else
            printf 'RESULT: FAIL (%s): %s\n' "$rc" "$test_file" >&2
            status=1
        fi
    fi
done

exit "$status"
