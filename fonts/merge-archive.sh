#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 || "$1" != *.zip ]]; then
    echo "Usage: $0 archive.zip [output.zip]" >&2
    exit 1
fi

archive=$1
output=${2:-$archive}
if [[ -e "$output" ]]; then
    echo "Output already exists: $output" >&2
    exit 1
fi

shopt -s nullglob
parts=("$archive".part[0-9][0-9][0-9])
if [[ ${#parts[@]} -eq 0 ]]; then
    echo "No parts found for $archive" >&2
    exit 1
fi
for ((i=0; i<${#parts[@]}; i++)); do
    printf -v expected '%s.part%03d' "$archive" "$i"
    if [[ ${parts[i]} != "$expected" ]]; then
        echo "Missing part: $expected" >&2
        exit 1
    fi
done

tmp=$(mktemp "${output}.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT
cat -- "${parts[@]}" > "$tmp"
if ! unzip -tq "$tmp" >/dev/null; then
    echo "Merged archive failed ZIP integrity check: $archive" >&2
    exit 1
fi
mv -- "$tmp" "$output"
echo "Created $output"
