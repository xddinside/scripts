# new code that only refreshes the wallpaper - 133 in undotree

#!/bin/zsh

# Prevent running duplicate scripts on reload
pgrep -f "$(basename "$0")" | grep -v "$$" >/dev/null && exit 0

monitor="eDP-1"  
LOGFILE="$HOME/auto-rotate.log"
SCR_DIR="$HOME/.local/share/bin"  # Path to your wallpaper script (if still used)
HYDE_CONF="$HOME/.config/hyde/hyde.conf"
THEMES_DIR="$HOME/.config/hyde/themes"

# Function to get the currently selected theme (if needed for wallpaper)
get_current_theme() {
    grep '^hydeTheme=' "$HYDE_CONF" | cut -d '=' -f2 | tr -d '"'
}

# Function to get the wallpaper path from the current theme (if needed)
get_wallpaper_path() {
    local theme=$(get_current_theme)
    local wall_set="$THEMES_DIR/$theme/wall.set"

    if [[ -L "$wall_set" ]]; then
        readlink "$wall_set"
    else
        echo ""
    fi
}

monitor-sensor | while read -r line; do
    echo "Sensor event: $line" >> "$LOGFILE"

    if echo "$line" | grep -q "Accelerometer orientation changed:"; then
        transform=0
        hyprctl keyword input:touchdevice:transform 0
        hyprctl keyword input:tablet:transform 0
        # For non-normal orientations, disable the keyboard; otherwise, re-enable it.
        if echo "$line" | grep -q "left-up"; then
            hyprctl keyword monitor "$monitor,1920x1200@120,auto,1,transform,1"
            hyprctl keyword input:touchdevice:transform 1
            hyprctl keyword input:tablet:transform 1
            hyprctl keyword "device[asus-keyboard-2]:enabled" false
            hyprctl keyword "device[epic-mouse-v1]:enabled" false
            transform=1
        elif echo "$line" | grep -q "bottom-up"; then
            hyprctl keyword monitor "$monitor,1920x1200@120,auto,1,transform,2"
            hyprctl keyword input:touchdevice:transform 2
            hyprctl keyword input:tablet:transform 2
            hyprctl keyword "device[asus-keyboard-2]:enabled" false
            hyprctl keyword "device[epic-mouse-v1]:enabled" false
            transform=2
        elif echo "$line" | grep -q "right-up"; then
            hyprctl keyword monitor "$monitor,1920x1200@120,auto,1,transform,3"
            hyprctl keyword input:touchdevice:transform 3
            hyprctl keyword input:tablet:transform 3
            hyprctl keyword "device[asus-keyboard-2]:enabled" false
            hyprctl keyword "device[epic-mouse-v1]:enabled" false
            transform=3
        elif echo "$line" | grep -q "normal"; then
            hyprctl keyword monitor "$monitor,1920x1200@120,auto,1,transform,0"
            hyprctl keyword input:touchdevice:transform 0
            hyprctl keyword input:tablet:transform 0
            hyprctl keyword "device[asus-keyboard-2]:enabled" true
            hyprctl keyword "device[epic-mouse-v1]:enabled" true
            transform=0
        fi

        # (Optional) If you're also dynamically setting the wallpaper, include that here.
        # wallpaper_path=$(get_wallpaper_path)
        # if [[ -n "$wallpaper_path" ]]; then
        #     "${SCR_DIR}/swwwallpaper.sh" -s "$wallpaper_path"
        #     echo "Applied wallpaper: $wallpaper_path with transform $transform" >> "$LOGFILE"
        # else
        #     echo "No valid wallpaper found!" >> "$LOGFILE"
        # fi
    fi
done

#   old code, that was refreshing the entire theme twice to fix the wallpaper
#   #!/bin/zsh

#   monitor="eDP-1"  # Check with `hyprctl monitors`
#   LOGFILE="$HOME/auto-rotate.log"
#   WALLSCRIPT="$HOME/.local/share/bin/swwwallpaper.sh"  # Adjust path if needed
#   THEME_SWITCHER="$HOME/.local/share/bin/themeswitch.sh"  # Path to the theme switcher script

#   monitor-sensor | while read -r line; do
#     echo "Sensor event: $line" >> "$LOGFILE"

#     if echo "$line" | grep -q "Accelerometer orientation changed:"; then
#       if echo "$line" | grep -q "left-up"; then
#         hyprctl keyword monitor "$monitor,1920x1200@120,auto,auto,transform,1"
#       elif echo "$line" | grep -q "bottom-up"; then
#         hyprctl keyword monitor "$monitor,1920x1200@120,auto,auto,transform,2"
#         sleep 0.5
#         $THEME_SWITCHER apply & sleep 1 && $THEME_SWITCHER apply &  # Run it twice after rotation
#       elif echo "$line" | grep -q "right-up"; then
#         hyprctl keyword monitor "$monitor,1920x1200@120,auto,auto,transform,3"
#       elif echo "$line" | grep -q "normal"; then
#         hyprctl keyword monitor "$monitor,1920x1200@120,auto,auto,transform,0"
#         sleep 0.5
#         $THEME_SWITCHER apply & sleep 1 && $THEME_SWITCHER apply &  # Run it twice after rotation
#       fi
#     fi
#   done

