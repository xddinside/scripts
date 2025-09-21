#!/bin/bash

# Check if ChatGPT is already running
if hyprctl clients | grep -q "chatgpt.com"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace chatgpt
else
    # If not running, launch it
    chromium --new-window --app="https://chatgpt.com/" --class=Chromium-chatgpt &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:chatgpt
fi

