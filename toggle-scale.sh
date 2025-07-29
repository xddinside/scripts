#!/bin/zsh

CONFIG_FILE="$HOME/.config/hypr/userprefs.conf"

sed -i 's/monitor = ,1920x1200@120,auto,1.5/monitor = ,1920x1200@120,auto,1.0/' "$CONFIG_FILE"
hyprctl reload

sleep 1

sed -i 's/monitor = ,1920x1200@120,auto,1.0/monitor = ,1920x1200@120,auto,1.5/' "$CONFIG_FILE"
hyprctl reload
