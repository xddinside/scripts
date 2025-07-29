#!/bin/bash

# Script to display Hyprland keybindings in fuzzel
# Usage: ./show-keybindings.sh

KEYBINDS_FILE="$HOME/.config/hypr/hyprland/keybinds.conf"
TEMP_FILE="/tmp/hypr_keybindings_$$_$(date +%s).txt"

# Ensure clean exit
trap 'rm -f "$TEMP_FILE"' EXIT

# Kill any existing fuzzel instances to prevent conflicts
pkill fuzzel 2>/dev/null || true
sleep 0.2

# Check if keybinds file exists
if [[ ! -f "$KEYBINDS_FILE" ]]; then
    notify-send "Error" "Keybinds file not found: $KEYBINDS_FILE"
    exit 1
fi

# Function to clean up and humanize action descriptions
humanize_action() {
    local action="$1"
    
    # Remove common prefixes
    action=$(echo "$action" | sed 's/^exec,[[:space:]]*//')
    action=$(echo "$action" | sed 's/^global,[[:space:]]*//')
    
    # Replace common application commands with friendly names
    action=$(echo "$action" | sed 's/app2unit -- ghostty/Open Terminal/')
    action=$(echo "$action" | sed 's/app2unit -- firefox/Open Firefox/')
    action=$(echo "$action" | sed 's/app2unit -- neovide/Open Neovide/')
    action=$(echo "$action" | sed 's/app2unit -- github-desktop/Open GitHub Desktop/')
    action=$(echo "$action" | sed 's/app2unit -- thunar/Open File Manager (Thunar)/')
    action=$(echo "$action" | sed 's/app2unit -- nemo/Open File Manager (Nemo)/')
    action=$(echo "$action" | sed 's/app2unit -- qps/Open Process Manager/')
    action=$(echo "$action" | sed 's/app2unit -- pavucontrol/Open Volume Control/')
    
    # Replace caelestia commands with descriptions
    action=$(echo "$action" | sed 's/caelestia:launcher/Show Application Launcher/')
    action=$(echo "$action" | sed 's/caelestia:launcherInterrupt/Hide Application Launcher/')
    action=$(echo "$action" | sed 's/caelestia:session/Show Session Menu/')
    action=$(echo "$action" | sed 's/caelestia:clearNotifs/Clear Notifications/')
    action=$(echo "$action" | sed 's/caelestia:brightnessUp/Increase Brightness/')
    action=$(echo "$action" | sed 's/caelestia:brightnessDown/Decrease Brightness/')
    action=$(echo "$action" | sed 's/caelestia:mediaToggle/Play\/Pause Media/')
    action=$(echo "$action" | sed 's/caelestia:mediaNext/Next Track/')
    action=$(echo "$action" | sed 's/caelestia:mediaPrevious/Previous Track/')
    action=$(echo "$action" | sed 's/caelestia:mediaStop/Stop Media/')
    
    # Replace workspace actions
    action=$(echo "$action" | sed 's/caelestia workspace-action workspace \([0-9]\+\)/Go to Workspace \1/')
    action=$(echo "$action" | sed 's/caelestia workspace-action workspacegroup \([0-9]\+\)/Go to Workspace Group \1/')
    action=$(echo "$action" | sed 's/caelestia workspace-action movetoworkspace \([0-9]\+\)/Move Window to Workspace \1/')
    action=$(echo "$action" | sed 's/caelestia workspace-action movetoworkspacegroup \([0-9]\+\)/Move Window to Workspace Group \1/')
    
    # Replace special workspace actions
    action=$(echo "$action" | sed 's/caelestia toggle specialws/Toggle Special Workspace/')
    action=$(echo "$action" | sed 's/caelestia toggle sysmon/Toggle System Monitor/')
    action=$(echo "$action" | sed 's/caelestia toggle music/Toggle Music Player/')
    action=$(echo "$action" | sed 's/caelestia toggle communication/Toggle Communication Apps/')
    action=$(echo "$action" | sed 's/caelestia toggle todo/Toggle Todo List/')
    
    # Replace screenshot and recording actions
    action=$(echo "$action" | sed 's/caelestia screenshot$/Take Full Screenshot/')
    action=$(echo "$action" | sed 's/caelestia screenshot region freeze/Take Region Screenshot (Freeze)/')
    action=$(echo "$action" | sed 's/caelestia screenshot region/Take Region Screenshot/')
    action=$(echo "$action" | sed 's/caelestia record -s/Record Screen with Sound/')
    action=$(echo "$action" | sed 's/caelestia record$/Record Screen/')
    action=$(echo "$action" | sed 's/caelestia record -r/Record Region/')
    
    # Replace clipboard and utility actions
    action=$(echo "$action" | sed 's/caelestia clipboard$/Show Clipboard History/')
    action=$(echo "$action" | sed 's/caelestia clipboard-delete/Delete from Clipboard History/')
    action=$(echo "$action" | sed 's/caelestia emoji-picker/Show Emoji Picker/')
    action=$(echo "$action" | sed 's/caelestia pip/Picture-in-Picture Mode/')
    
    # Replace common Hyprland actions
    action=$(echo "$action" | sed 's/workspace, -1/Previous Workspace/')
    action=$(echo "$action" | sed 's/workspace, +1/Next Workspace/')
    action=$(echo "$action" | sed 's/workspace, -10/Previous Workspace Group/')
    action=$(echo "$action" | sed 's/workspace, +10/Next Workspace Group/')
    action=$(echo "$action" | sed 's/movetoworkspace, -1/Move Window to Previous Workspace/')
    action=$(echo "$action" | sed 's/movetoworkspace, +1/Move Window to Next Workspace/')
    action=$(echo "$action" | sed 's/movetoworkspace, special:special/Move Window to Special Workspace/')
    action=$(echo "$action" | sed 's/movetoworkspace, e+0/Move Window to Current Workspace/')
    
    action=$(echo "$action" | sed 's/movefocus, l/Focus Left Window/')
    action=$(echo "$action" | sed 's/movefocus, r/Focus Right Window/')
    action=$(echo "$action" | sed 's/movefocus, u/Focus Up Window/')
    action=$(echo "$action" | sed 's/movefocus, d/Focus Down Window/')
    
    action=$(echo "$action" | sed 's/movewindow, l/Move Window Left/')
    action=$(echo "$action" | sed 's/movewindow, r/Move Window Right/')
    action=$(echo "$action" | sed 's/movewindow, u/Move Window Up/')
    action=$(echo "$action" | sed 's/movewindow, d/Move Window Down/')
    
    action=$(echo "$action" | sed 's/splitratio, -0.1/Decrease Window Size/')
    action=$(echo "$action" | sed 's/splitratio, 0.1/Increase Window Size/')
    action=$(echo "$action" | sed 's/togglefloating,$/Toggle Floating Mode/')
    action=$(echo "$action" | sed 's/fullscreen, 0/Toggle Fullscreen/')
    action=$(echo "$action" | sed 's/fullscreen, 1/Toggle Fullscreen (with borders)/')
    action=$(echo "$action" | sed 's/killactive,$/Close Window/')
    action=$(echo "$action" | sed 's/pin$/Pin Window/')
    action=$(echo "$action" | sed 's/centerwindow, 1/Center Window/')
    action=$(echo "$action" | sed 's/togglegroup$/Toggle Window Group/')
    action=$(echo "$action" | sed 's/lockactivegroup, toggle/Toggle Group Lock/')
    action=$(echo "$action" | sed 's/changegroupactive, f/Next Window in Group/')
    action=$(echo "$action" | sed 's/changegroupactive, b/Previous Window in Group/')
    
    # Replace system actions
    action=$(echo "$action" | sed 's/loginctl lock-session/Lock Screen/')
    action=$(echo "$action" | sed 's/systemctl suspend-then-hibernate/Sleep and Hibernate/')
    action=$(echo "$action" | sed 's/hyprpicker -a/Color Picker/')
    action=$(echo "$action" | sed 's/hyprctl reload/Reload Hyprland Config/')
    
    # Replace volume controls
    action=$(echo "$action" | sed 's/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle/Toggle Mute/')
    action=$(echo "$action" | sed 's/.*wpctl set-volume.*2%+.*/Increase Volume/')
    action=$(echo "$action" | sed 's/.*wpctl set-volume.*2%-.*/Decrease Volume/')
    
    # Replace fuzzel launcher
    action=$(echo "$action" | sed 's/pkill fuzzel || fuzzel --launch-prefix.*$/Secondary App Launcher/')
    
    # Handle comments after actions
    if [[ "$action" =~ ^(.*)#[[:space:]]*(.*)$ ]]; then
        local main_action="${BASH_REMATCH[1]}"
        local comment="${BASH_REMATCH[2]}"
        # If comment is more descriptive, use it
        if [[ ${#comment} -gt 5 && ${#comment} -lt ${#main_action} ]]; then
            action="$comment"
        else
            action="$main_action"
        fi
    fi
    
    # Clean up any remaining whitespace
    action=$(echo "$action" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    
    echo "$action"
}

# Function to format keybinding display
format_keybinding() {
    local line="$1"
    
    # Skip empty lines and comments
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
        return
    fi
    
    # Skip exec and submap lines
    if [[ "$line" =~ ^exec ]] || [[ "$line" =~ ^submap ]]; then
        return
    fi
    
    # Extract bind type, modifiers+key, and action
    # Handle different bind formats: bind = mod, key, action and bind = mod, key, exec, action
    if [[ "$line" =~ ^(bind[a-z]*)[[:space:]]*=[[:space:]]*([^,]*),?[[:space:]]*([^,]+),[[:space:]]*(.+)$ ]]; then
        local bind_type="${BASH_REMATCH[1]}"
        local modifiers="${BASH_REMATCH[2]}"
        local key="${BASH_REMATCH[3]}"
        local action="${BASH_REMATCH[4]}"
        
        # Handle the case where there's a middle argument (like "global" or "exec")
        if [[ "$action" =~ ^(global|exec),[[:space:]]*(.+)$ ]]; then
            action="${BASH_REMATCH[2]}"
        fi
        
        # Humanize the action description
        action=$(humanize_action "$action")
        
        # Format the display
        local display_key
        if [[ "$modifiers" == "," ]] || [[ -z "$modifiers" ]]; then
            display_key="$key"
        else
            display_key="$modifiers + $key"
        fi
        
        # Clean up key display
        display_key=$(echo "$display_key" | sed 's/Super/󰘳/')
        display_key=$(echo "$display_key" | sed 's/Ctrl/Ctrl/')
        display_key=$(echo "$display_key" | sed 's/Alt/Alt/')
        display_key=$(echo "$display_key" | sed 's/Shift/⇧/')
        display_key=$(echo "$display_key" | sed 's/Page_Up/PgUp/')
        display_key=$(echo "$display_key" | sed 's/Page_Down/PgDn/')
        display_key=$(echo "$display_key" | sed 's/Backslash/\\/')
        display_key=$(echo "$display_key" | sed 's/Return/Enter/')
        display_key=$(echo "$display_key" | sed 's/Escape/Esc/')
        display_key=$(echo "$display_key" | sed 's/Delete/Del/')
        display_key=$(echo "$display_key" | sed 's/Slash/\//')
        display_key=$(echo "$display_key" | sed 's/Period/\./')
        display_key=$(echo "$display_key" | sed 's/Comma/,/')
        display_key=$(echo "$display_key" | sed 's/Minus/-/')
        display_key=$(echo "$display_key" | sed 's/Equal/=/')
        
        # Truncate long actions
        if [[ ${#action} -gt 80 ]]; then
            action="${action:0:77}..."
        fi
        
        # Use printf with exact width for alignment
        printf "%-35s │ %s\n" "$display_key" "$action"
    fi
}

# Parse keybindings and create formatted output
{
    echo "=== HYPRLAND KEYBINDINGS ==="
    echo ""
    
    # Much simpler sed-based parsing
    grep -E '^bind[a-z]* =' "$KEYBINDS_FILE" | \
    grep -v 'mouse\|catchall' | \
    sed 's/^bind[a-z]* = //' | \
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue
        
        # Use cut to split by commas
        modifiers=$(echo "$line" | cut -d',' -f1 | xargs)
        key=$(echo "$line" | cut -d',' -f2 | xargs)
        
        # Get action - handle global/exec prefix
        action=$(echo "$line" | cut -d',' -f3- | xargs)
        if [[ "$action" =~ ^(global|exec),[[:space:]]* ]]; then
            action=$(echo "$line" | cut -d',' -f4- | xargs)
        fi
        
        # Skip if any essential part is missing
        [[ -z "$key" || -z "$action" ]] && continue
        
        # Format display key
        if [[ -z "$modifiers" || "$modifiers" == " " ]]; then
            display_key="$key"
        else
            display_key="$modifiers + $key"
        fi
        
        # Clean up key display with simple substitutions
        display_key="${display_key//Super/󰘳}"
        display_key="${display_key//Shift/⇧}"
        display_key="${display_key//Page_Up/PgUp}"
        display_key="${display_key//Page_Down/PgDn}"
        display_key="${display_key//Backslash/\\}"
        display_key="${display_key//Return/Enter}"
        display_key="${display_key//Escape/Esc}"
        display_key="${display_key//Delete/Del}"
        display_key="${display_key//Slash/\/}"
        display_key="${display_key//Period/.}"
        display_key="${display_key//Comma/,}"
        display_key="${display_key//Minus/-}"
        display_key="${display_key//Equal/=}"
        
        # Humanize the action description
        action=$(humanize_action "$action")
        
        # Truncate long actions
        if [[ ${#action} -gt 80 ]]; then
            action="${action:0:77}..."
        fi
        
        # Use printf with exact width for alignment
        printf "%-35s │ %s\n" "$display_key" "$action"
    done
    
} > "$TEMP_FILE"

# Check if we should just output to terminal (for debugging)
if [[ "$1" == "--debug" ]]; then
    cat "$TEMP_FILE"
    exit 0
fi

# Launch fuzzel with the keybindings
if command -v fuzzel >/dev/null 2>&1; then
    fuzzel --dmenu --prompt="Keybindings: " --width=85 --lines=30 --font="JetBrainsMono Nerd Font:size=14" < "$TEMP_FILE" || {
        # If fuzzel fails, show error and fallback
        notify-send "Error" "Fuzzel failed to launch. Check if another instance is running."
        cat "$TEMP_FILE"
    }
else
    # Fallback to rofi if fuzzel is not available
    if command -v rofi >/dev/null 2>&1; then
        rofi -dmenu -i -p "Keybindings" -theme-str 'window {width: 80%;} listview {lines: 25;}' < "$TEMP_FILE"
    else
        # Last resort: display in terminal
        cat "$TEMP_FILE"
    fi
fi

