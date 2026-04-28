#!/bin/bash

# create temporary directory
TEMP_DIR=$(mktemp -d)

# clone the repostitory
echo "Clone Repository ..."
git clone --depth 1 https://github.com/kaikuhn/PlutoLauncher.git "$TEMP_DIR" || {
    echo "ERROR: Repository could not be cloned"
    exit 1
}

# change directory
cd $TEMP_DIR

# define paths
ENV_DIR="$HOME/.local/share/pluto_env"
BROWSER_ENV_DIR="$HOME/.local/share/pluto_env/browser"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
# files
SCRIPT="pluto_server.jl"
BROWSER="pluto_browser.sh"
DESKTOP="pluto.desktop"
ICON="pluto.svg"
SERVICE="pluto.service"
SCRIPT_PATH="$BIN_DIR/$SCRIPT"
BROWSER_PATH="$BIN_DIR/$BROWSER"
DESKTOP_PATH="$APP_DIR/$DESKTOP"
ICON_PATH="$ICON_DIR/$ICON"
SERVICE_PATH="$HOME/.config/systemd/user/$SERVICE"

# stop service
systemctl --user stop pluto.service
systemctl --user disable pluto.service

# delete files
echo "Deleting files ..."
rm "$SCRIPT_PATH"
rm "$BROWSER_PATH"
rm "$DESKTOP_PATH"
rm "$SERVICE_PATH"
rm "$ICON_PATH"
rm -r "$ENV_DIR"

# clean up
echo "Cleaning up ..."
cd ..
rm -rf "$TEMP_DIR"

echo "Finished!"
echo "The Desktop Entry may disappear after restarting the system."
