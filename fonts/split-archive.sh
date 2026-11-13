#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" || "$1" != *.zip ]]; then
    echo "Usage: $0 archive.zip" >&2
    exit 1
fi

archive=$1
if compgen -G "${archive}.part[0-9][0-9][0-9]" >/dev/null; then
    echo "Parts already exist for $archive; remove or move them first." >&2
    exit 1
fi

split -b 49m -d -a 3 -- "$archive" "${archive}.part"
echo "Created ${archive}.part000 and subsequent parts."
