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
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
ENV_DIR="$HOME/.pluto_launcher_env"
NOTEBOOK_DIR="$HOME/PlutoNotebooks"
SCRIPT="pluto.jl"
WRAPPER="pluto_wrapper.sh"
DESKTOP="pluto.desktop"
ICON="pluto.svg"
SCRIPT_PATH="$BIN_DIR/$SCRIPT"
WRAPPER_PATH="$BIN_DIR/$WRAPPER"
DESKTOP_PATH="$APP_DIR/$DESKTOP"
ICON_PATH="$ICON_DIR/$ICON"

# delete files
echo "Deleting files ..."
rm "$SCRIPT_PATH"
rm "$WRAPPER_PATH"
rm "$DESKTOP_PATH"
rm "$ICON_PATH"
rm -r "$ENV_DIR"
rm -r "$NOTEBOOK_DIR"

# clean up
echo "Cleaning up ..."
cd ..
rm -rf "$TEMP_DIR"

echo "Finished!"
echo "The Desktop Entry may disappear after restarting the system."
