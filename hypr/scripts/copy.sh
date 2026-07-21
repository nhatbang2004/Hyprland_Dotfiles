#!/bin/bash

FILE="$HOME/Documents/copy.txt"

wl-copy < <(wl-paste -p)

TEXT=$(wl-paste)

[ -z "$TEXT" ] && exit 0

if [ -f "$FILE" ]; then
  COUNT=$(grep -c '^=== [0-9]\+ ===$' "$FILE")
else
  COUNT=0
fi

COUNT=$((COUNT + 1))

{
  echo "=== $COUNT ==="
  echo "$TEXT"
  echo
} >>"$FILE"
