#!/bin/bash

# Check if WhatsApp is already running
if hyprctl clients | grep -q "web.whatsapp.com"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace whatsapp
else
    # If not running, launch it
    chromium --new-window --app="https://web.whatsapp.com/" --class=Chromium-whatsapp &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:whatsapp
fi
