#!/bin/bash

WALL_DIR="$HOME/Pictures/Live_Wallpaper"
TEMP_THUMB="/tmp/wall_thumb.png"

SELECTED=$(
find "$WALL_DIR" -type f -iname "*.mp4" \
| while read -r video; do
    thumb="/tmp/$(basename "${video%.*}").png"

    # Tạo thumbnail nếu chưa có
    [ ! -f "$thumb" ] && \
        ffmpeg -loglevel quiet -y -ss 00:00:01 -i "$video" -vframes 1 "$thumb"

    printf '%s\0icon\x1f%s\n' "$(basename "$video")" "$thumb"
done \
| rofi -dmenu \
    -i \
    -show-icons \
    -theme "$HOME/.config/rofi/wallselect/style.rasi"
)

[ -z "$SELECTED" ] && exit 0

VIDEO_PATH=$(find "$WALL_DIR" -type f | grep "/$SELECTED$" | head -n1)
[ -z "$VIDEO_PATH" ] && exit 1

# Lấy frame đầu để tạo màu
ffmpeg -loglevel quiet -y -i "$VIDEO_PATH" -vframes 1 "$TEMP_THUMB"

# Tạo theme bằng Matugen
matugen image "$TEMP_THUMB" --source-color-index 0

# Hiệu ứng chuyển bằng swww
awww img "$TEMP_THUMB" \
    --transition-type fade \
    --transition-step 255 \
    --transition-fps 270

# Restart mpvpaper
pkill mpvpaper 2>/dev/null

mpvpaper -o "--loop --hwdec=nvdec --no-audio" eDP-1 "$VIDEO_PATH" &
mpvpaper -o "--loop --hwdec=nvdec --no-audio" HDMI-A-1 "$VIDEO_PATH" &

notify-send "Themes Updated!" 
