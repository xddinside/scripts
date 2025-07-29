#!/bin/bash

# Check if Claude is already running
if hyprctl clients | grep -q "claude"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace claude
else
    # If not running, launch it
    chromium --new-window --app="https://claude.ai/" --class=Chromium-claude &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:claude
fi
