#!/bin/bash

FILE="$HOME/Documents/copy.txt"

# Copy vùng chọn vào clipboard
wl-copy < <(wl-paste -p)

TEXT=$(wl-paste)

# Bỏ qua nếu không có nội dung
[ -z "$TEXT" ] && exit 0

# Đếm số mục đã lưu
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
