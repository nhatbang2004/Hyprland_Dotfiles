#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$PATH"

wallpapers_dir="$HOME/Pictures/Wallpapers"

random_wallpaper=$(find "$wallpapers_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

[ -z "$random_wallpaper" ] && exit 1

matugen image "$random_wallpaper" --source-color-index 0
awww img "$random_wallpaper" --transition-type random

notify-send "Theme Updated!"
