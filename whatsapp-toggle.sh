#!/bin/bash

CLASS="chrome-web.whatsapp.com__-Default"
WORKSPACE="special:whatsapp"
URL="https://web.whatsapp.com/"

# Get window address by class
get_window_addr() {
    hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address" | head -n1
}

window_addr=$(get_window_addr)

if [[ -n "$window_addr" ]]; then
    # Window exists, toggle the special workspace
    hyprctl dispatch togglespecialworkspace whatsapp
else
    # Launch the webapp
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
        hyprctl dispatch togglespecialworkspace whatsapp
    fi
fi
