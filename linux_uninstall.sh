#!/bin/bash

# define paths
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
SCRIPT="pluto_launcher.jl"
WRAPPER="pluto_launcher.sh"
SCRIPT_PATH="$BIN_DIR/$SCRIPT"
WRAPPER_PATH="$BIN_DIR/$WRAPPER"
DESKTOP_PATH="$APP_DIR/pluto_launcher.desktop"

# delete files
echo "Deleting files ..."
rm "$SCRIPT_PATH"
rm "$WRAPPER_PATH"
rm "$DESKTOP_PATH"

echo "Finished!"
echo "The Desktop Entry may disappear after restarting the system."