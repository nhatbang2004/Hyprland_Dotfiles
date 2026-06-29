#!/bin/bash

WALL_DIR="$HOME/Pictures/Wallpapers"

SELECTED=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
    | while read -r img; do
        printf '%s\0icon\x1f%s\n' "$(basename "$img")" "$img"
      done \
    | rofi -dmenu -i -show-icons -theme "$HOME/.config/rofi/wallselect/style.rasi"
)

[ -z "$SELECTED" ] && exit 0

# map lại tên -> full path
SELECTED_PATH=$(find "$WALL_DIR" -type f \
    | grep "/$SELECTED$" | head -n 1)

[ -z "$SELECTED_PATH" ] && exit 1


matugen image "$SELECTED_PATH" --source-color-index 0
awww img "$SELECTED_PATH" --transition-type random

notify-send "Theme Updated!"
