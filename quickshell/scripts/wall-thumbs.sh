#!/usr/bin/env bash

set -u
 
SRC="${1:-$HOME/Pictures/Wallpapers}"
DST="${2:-$HOME/.cache/wallpaper-thumbs}"
GEOM="900x420^"   # '^' = scale theo kiểu phủ kín, không bị mờ do phóng to
JOBS=4
 
command -v magick >/dev/null 2>&1 || exit 0
[ -d "$SRC" ] || exit 0
mkdir -p "$DST" || exit 0
 
# 1) Tạo thumbnail còn thiếu hoặc đã cũ.
while IFS= read -r -d '' img; do
    out="$DST/$(basename "$img").jpg"
    if [ -s "$out" ] && [ ! "$img" -nt "$out" ]; then
        continue
    fi

    ( magick "${img}[0]" -auto-orient -background "#000000" -alpha remove -alpha off \
            -thumbnail "$GEOM" -strip -quality 85 "jpg:$out.tmp" 2>/dev/null \
        && mv -f -- "$out.tmp" "$out" || rm -f -- "$out.tmp" ) &
    while [ "$(jobs -rp | wc -l)" -ge "$JOBS" ]; do wait -n; done
done < <(find "$SRC" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
       -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.avif' \) -print0)
wait
 

find "$DST" -maxdepth 1 -type f -name '*.jpg.tmp' -delete 2>/dev/null
 

while IFS= read -r -d '' thumb; do
    base="$(basename "$thumb")"
    [ -f "$SRC/${base%.jpg}" ] || rm -f -- "$thumb"
done < <(find "$DST" -maxdepth 1 -type f -name '*.jpg' -print0)
 
exit 0
 