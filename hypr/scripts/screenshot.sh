#!/usr/bin/env bash
sleep 0.1
grim -g "$(slurp)" "$HOME/Pictures/Screenshots"/"$(date +%Y%m%d-%H%M%S)".png
wl-copy <  "$HOME/Pictures/Screenshots"/"$(date +%Y%m%d-%H%M%S)".png
