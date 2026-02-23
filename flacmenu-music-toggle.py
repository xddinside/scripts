#!/usr/bin/env python3

import json
import subprocess
import sys
import time

MUSIC_WORKSPACE = "music"
FLACMENU_CMD = [
    "app2unit",
    "--",
    "kitty",
    "--title",
    "flacmenu",
    "-e",
    "bash",
    "-lc",
    "/home/xdd/scripts/flacmenu",
]
FLACMENU_FALLBACK_CMD = [
    "kitty",
    "--title",
    "flacmenu",
    "-e",
    "bash",
    "-lc",
    "/home/xdd/scripts/flacmenu",
]


def run_hyprctl(command, args=""):
    try:
        cmd = ["hyprctl", command]
        if args:
            cmd.extend(args.split())
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as exc:
        print(f"hyprctl error: {exc}", file=sys.stderr)
        return None


def dispatch_hyprctl(command, args=""):
    cmd_args = f"dispatch {command}"
    if args:
        cmd_args += f" {args}"
    run_hyprctl(cmd_args.split()[0], " ".join(cmd_args.split()[1:]))


def get_clients():
    output = run_hyprctl("clients", "-j")
    if not output:
        return []
    try:
        clients = json.loads(output)
        if isinstance(clients, list):
            return clients
    except json.JSONDecodeError:
        pass
    return []


def client_workspace_name(client):
    workspace = client.get("workspace")
    if isinstance(workspace, dict):
        return workspace.get("name", "")
    return ""


def is_flacmenu_client(client):
    title = (client.get("title") or "").lower()
    initial_title = (client.get("initialTitle") or "").lower()
    # Reuse only the launcher window, not the mpv playback window.
    return (
        ("flacmenu" in title and "flacmenu-mpv" not in title)
        or ("flacmenu" in initial_title and "flacmenu-mpv" not in initial_title)
    )


def find_flacmenu_client(clients):
    preferred = None
    for client in clients:
        if not is_flacmenu_client(client):
            continue
        if client_workspace_name(client) == f"special:{MUSIC_WORKSPACE}":
            return client
        if preferred is None:
            preferred = client
    return preferred


def move_client_to_music(client):
    address = client.get("address")
    if not address:
        return
    dispatch_hyprctl(
        "movetoworkspacesilent",
        f"special:{MUSIC_WORKSPACE},address:{address}",
    )


def focus_client(client):
    address = client.get("address")
    if not address:
        return
    dispatch_hyprctl("focuswindow", f"address:{address}")


def is_music_workspace_visible():
    output = run_hyprctl("monitors", "-j")
    if not output:
        return False

    try:
        monitors = json.loads(output)
    except json.JSONDecodeError:
        return False

    target = f"special:{MUSIC_WORKSPACE}"
    for monitor in monitors:
        special_ws = monitor.get("specialWorkspace")
        if isinstance(special_ws, dict) and special_ws.get("name") == target:
            return True
    return False


def ensure_music_workspace_visible():
    # Keep music special workspace visible; never hide it from this keybind.
    if not is_music_workspace_visible():
        dispatch_hyprctl("togglespecialworkspace", MUSIC_WORKSPACE)


def launch_flacmenu():
    try:
        subprocess.Popen(FLACMENU_CMD, start_new_session=True)
        return
    except Exception as exc:
        print(f"app2unit launch failed, falling back to kitty: {exc}", file=sys.stderr)
    try:
        subprocess.Popen(FLACMENU_FALLBACK_CMD, start_new_session=True)
    except Exception as fallback_exc:
        print(f"Fallback launch failed: {fallback_exc}", file=sys.stderr)


def wait_for_flacmenu_client(timeout_seconds=5.0, interval_seconds=0.1):
    deadline = time.monotonic() + timeout_seconds
    while time.monotonic() < deadline:
        client = find_flacmenu_client(get_clients())
        if client is not None:
            return client
        time.sleep(interval_seconds)
    return None


def main():
    existing = find_flacmenu_client(get_clients())
    if existing is not None:
        if client_workspace_name(existing) != f"special:{MUSIC_WORKSPACE}":
            move_client_to_music(existing)
        ensure_music_workspace_visible()
        focus_client(existing)
        return

    ensure_music_workspace_visible()
    launch_flacmenu()

    spawned = wait_for_flacmenu_client()
    if spawned is not None:
        if client_workspace_name(spawned) != f"special:{MUSIC_WORKSPACE}":
            move_client_to_music(spawned)
        focus_client(spawned)


if __name__ == "__main__":
    main()
