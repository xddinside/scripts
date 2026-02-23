#!/usr/bin/env python3

import subprocess
import json
import sys

def run_hyprctl(command, args=""):
    """Run hyprctl command and return output"""
    try:
        cmd = ["hyprctl", command]
        if args:
            cmd.extend(args.split())
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running hyprctl: {e}", file=sys.stderr)
        return None

def get_clients():
    """Get list of all clients from Hyprland"""
    output = run_hyprctl("clients", "-j")
    if output:
        try:
            return json.loads(output)
        except json.JSONDecodeError:
            print("Error parsing client data", file=sys.stderr)
    return []

def dispatch_hyprctl(command, args=""):
    """Send dispatch command to Hyprland"""
    cmd_args = f"dispatch {command}"
    if args:
        cmd_args += f" {args}"
    run_hyprctl(cmd_args.split()[0], " ".join(cmd_args.split()[1:]))

def spawn_app(command_list):
    """Spawn an application using app2unit"""
    try:
        subprocess.Popen(["app2unit", "--", *command_list], start_new_session=True)
        return True
    except Exception as e:
        print(f"Error spawning app: {e}", file=sys.stderr)
        return False

def find_client(clients, selector_func):
    """Find a client matching the selector function"""
    return next((client for client in clients if selector_func(client)), None)

def move_client_to_workspace(client, workspace):
    """Move a specific client to a workspace"""
    if client:
        dispatch_hyprctl("movetoworkspacesilent", f"special:{workspace},address:{client['address']}")

def client_workspace_name(client):
    """Get a client's workspace name safely"""
    workspace = client.get("workspace")
    if isinstance(workspace, dict):
        return workspace.get("name", "")
    return ""

def is_flacmenu_music_client(client):
    """Check if client belongs to flacmenu/mpv session in special:music"""
    ws_name = client_workspace_name(client)
    if ws_name != "special:music":
        return False

    title = (client.get("title") or "").lower()
    initial_title = (client.get("initialTitle") or "").lower()

    return (
        "flacmenu" in title
        or "flacmenu" in initial_title
        or "flacmenu-mpv" in title
        or "flacmenu-mpv" in initial_title
    )

def toggle_music_workspace():
    """Main function to toggle music workspace"""
    clients = get_clients()

    # If flacmenu/mpv session is already in the music workspace, just toggle visibility.
    flacmenu_client = find_client(clients, is_flacmenu_music_client)
    if flacmenu_client:
        print("Toggling music workspace for flacmenu/mpv session...")
        dispatch_hyprctl("togglespecialworkspace", "music")
        return
    
    # Check if Cider is running
    cider_client = find_client(clients, lambda c: 
        c.get("class") == "Cider" or 
        c.get("initialTitle") == "Cider" or
        "cider" in c.get("title", "").lower()
    )
    
    # If Cider not found, spawn it using your script
    if not cider_client:
        print("Spawning Cider...")
        spawn_app(["/home/xdd/scripts/cider-xscale"]) 
    else:
        # Move existing Cider to music workspace
        print("Moving Cider to music workspace...")
        move_client_to_workspace(cider_client, "music")
    
    # Check for feishin and move it if found
    feishin_client = find_client(clients, lambda c: c.get("class") == "feishin")
    if feishin_client:
        print("Moving feishin to music workspace...")
        move_client_to_workspace(feishin_client, "music")
    
    # Toggle the special music workspace
    print("Toggling music workspace...")
    dispatch_hyprctl("togglespecialworkspace", "music")

if __name__ == "__main__":
    toggle_music_workspace()
