#!/usr/bin/env bash

set -uo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE="$CACHE/current-wallpaper"
TRANSITION="${WALL_TRANSITION:-random}"

case "${1:-}" in
-h | --help | "")
  echo "usage: set-wallpaper.sh <image> | --restore"
  exit 0
  ;;
--restore)
  [ -s "$STATE" ] || exit 0
  IMG="$(<"$STATE")"
  ;;
*)
  IMG="$1"
  ;;
esac

IMG="$(realpath -- "$IMG")" || exit 1
if [ ! -f "$IMG" ]; then
  notify-send -u critical "Wallpaper" "Không tìm thấy ảnh: $IMG" 2>/dev/null || true
  exit 1
fi

if exec 9>"${XDG_RUNTIME_DIR:-/tmp}/set-wallpaper.lock" 2>/dev/null; then
  flock 9
fi

if ! awww query >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 9>&- &
  disown
  for _ in {1..50}; do
    sleep 0.1
    awww query >/dev/null 2>&1 && break
  done
fi

awww img "$IMG" --transition-type "$TRANSITION"

mkdir -p "$CACHE"
printf '%s' "$IMG" >"$STATE"
matugen image "$IMG" --source-color-index 0
exit 0
