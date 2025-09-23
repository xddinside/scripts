#!/bin/bash

# Check if ChatGPT is already running
if hyprctl clients | grep -q "chrome-t3.chat"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace t3
else
    # If not running, launch it
    chromium --new-window --app="https://t3.chat/" --class=Chromium-t3 &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:t3
fi

