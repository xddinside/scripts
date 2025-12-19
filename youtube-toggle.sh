#!/bin/bash

CLASS="chrome-youtube.com__-Default"
WORKSPACE="special:youtube"
URL="https://youtube.com/"

# Get window address by class
get_window_addr() {
    hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address" | head -n1
}

window_addr=$(get_window_addr)

if [[ -n "$window_addr" ]]; then
    # Window exists, toggle the special workspace
    hyprctl dispatch togglespecialworkspace youtube
else
    # Launch the webapp with specific class
    chromium --new-window --app="$URL" &
    
    # Wait for window to appear (poll instead of fixed sleep)
    for i in {1..50}; do
        sleep 0.1
        window_addr=$(get_window_addr)
        if [[ -n "$window_addr" ]]; then
            break
        fi
    done
    
    # Move only this specific window to the special workspace
    if [[ -n "$window_addr" ]]; then
        hyprctl dispatch movetoworkspacesilent "$WORKSPACE,address:$window_addr"
        hyprctl dispatch togglespecialworkspace youtube
    fi
fi
