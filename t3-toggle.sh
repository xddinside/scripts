#!/bin/bash

CLASS="chrome-t3.chat__-Default"
WORKSPACE="special:t3"
URL="https://t3.chat/"

# Get window address by class
get_window_addr() {
    hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address" | head -n1
}

window_addr=$(get_window_addr)

if [[ -n "$window_addr" ]]; then
    # Window exists, toggle the special workspace
    hyprctl dispatch togglespecialworkspace t3
else
    # Launch the webapp with helium-browser and scaling
    helium-browser --new-window --app="$URL" --force-device-scale-factor=1.3 &
    
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
        hyprctl dispatch togglespecialworkspace t3
    fi
fi
