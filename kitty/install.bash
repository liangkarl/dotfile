#!/usr/bin/env bash

# The installer only touches files in that directory. To update kitty, simply re-run the command.
curl -k -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
