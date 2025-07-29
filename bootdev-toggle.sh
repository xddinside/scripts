#!/bin/bash
# Check if bootdev is running already
if hyprctl clients | grep -q "boot.dev"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace bootdev
else
    # If not running, launch it
    chromium --new-window --app="https://boot.dev/" --class=Chromium-bootdev &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:bootdev
fi
