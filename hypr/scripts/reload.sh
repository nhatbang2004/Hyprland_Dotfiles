#!/bin/bash

killall -9 swaync
systemctl --user restart waybar
swaync
