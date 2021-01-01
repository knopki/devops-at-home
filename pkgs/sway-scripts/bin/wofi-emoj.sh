#!/usr/bin/env bash
set -euo pipefail

Q=$(echo "" | wofi -k /dev/null -e -L1 -d -p "Emoji")
emoj "${Q}" | sed 's/  /\n/g' | wofi -k /dev/null -L5 -d -p "Select Emoji" | tr -d '\n' | wl-copy
