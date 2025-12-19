#!/bin/zsh

# Prevent running duplicate scripts on reload
pgrep -f "$(basename "$0")" | grep -v "$$" >/dev/null && exit 0

# ============================================
# Configuration
# ============================================
MONITOR="eDP-1"
RESOLUTION="1920x1200"
REFRESH_RATE="120"
SCALE="1"

KEYBOARD_DEVICE="asus-keyboard-2"
MOUSE_DEVICE="epic-mouse-v1"

LOGFILE="$HOME/auto-rotate.log"

# ============================================
# Helper Functions
# ============================================
log_message() {
    echo "$1" >> "$LOGFILE"
}

apply_rotation() {
    local transform="$1"
    local keyboard_enabled="$2"

    hyprctl keyword monitor "$MONITOR,${RESOLUTION}@${REFRESH_RATE},auto,${SCALE},transform,${transform}"
    hyprctl keyword input:touchdevice:transform "$transform"
    hyprctl keyword input:tablet:transform "$transform"
    hyprctl keyword "device[${KEYBOARD_DEVICE}]:enabled" "$keyboard_enabled"
    hyprctl keyword "device[${MOUSE_DEVICE}]:enabled" "$keyboard_enabled"
}

# ============================================
# Main Loop
# ============================================
monitor-sensor | while read -r line; do
    log_message "Sensor event: $line"

    case "$line" in
        *"Accelerometer orientation changed:"*)
            case "$line" in
                *"left-up"*)   apply_rotation 1 false ;;
                *"bottom-up"*) apply_rotation 2 false ;;
                *"right-up"*)  apply_rotation 3 false ;;
                *"normal"*)    apply_rotation 0 true  ;;
            esac
            ;;
    esac
done
