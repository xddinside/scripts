#!/bin/bash

# Check if Perplexity is already running
if hyprctl clients | grep -q "perplexity.ai"; then
    # If running, toggle the special workspace
    hyprctl dispatch togglespecialworkspace perplexity
else
    # If not running, launch it
    chromium --new-window --app="https://perplexity.ai/" --class=Chromium-perplexity &
    sleep 1
    # Move to special workspace after launch
    hyprctl dispatch movetoworkspace special:perplexity
fi
