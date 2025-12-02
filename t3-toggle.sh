#!/bin/bash

# Check if ChatGPT is already running
if hyprctl clie
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace t3
else
    # If not running, launch it
    helium-browser --new-window --app="https://t3.chat/" --class=Chromium-t3 --force-device-scale-factor=1.3 &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:t3
fi

