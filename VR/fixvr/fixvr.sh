#!/bin/bash
# Path to SteamVR tools (Standard Arch/Steam path)
# If you installed Steam via Flatpak, paths will differ.
STEAMVR_PATH="$HOME/.local/share/Steam/steamapps/common/SteamVR"
CONSOLE="$STEAMVR_PATH/tools/lighthouse/bin/linux64/lighthouse_console"

# Send the reboot command to the headset
echo -e "reboot\nquit" | "$CONSOLE"
