#!/bin/bash

# Check if Gemini is already running
if hyprctl clients | grep -q "gemini.google.com"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace gemini
else
    # If not running, launch it
    chromium --new-window --app="https://gemini.google.com/app" --class=Chromium-gemini &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:gemini
fi
