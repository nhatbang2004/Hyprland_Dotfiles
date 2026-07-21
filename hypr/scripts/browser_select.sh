#!/usr/bin/env bash

choice=$(printf "Firefox\nChrome" | rofi -dmenu -i -p "Browser" -theme-str 'listview {lines: 2;}')

case "$choice" in
Firefox) exec firefox ;;
Chrome) exec google-chrome-stable ;;
esac
