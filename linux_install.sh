#!/bin/bash

# Install Julia, if necessary
if command -v julia &> /dev/null; then
    echo "Julia is already installed. OK ..."
else
    echo "Julia will be installed ..."
    curl -fsSL https://install.julialang.org | sh -s -- -y

    echo "Installation completed!"
    echo "Please restart the shell and start the Installation script again!"
    exit 0
fi

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

# Preapare Julia environment for Pluto
echo "Prepare Julia environment ..."
mkdir -p "$ENV_DIR"
mkdir -p "$BROWSER_ENV_DIR"

julia --project="$ENV_DIR" -e '
    using Pkg;
    Pkg.add("Pluto");
'

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

# create folders
echo "Create folders ..."
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"

# copy files
echo "Copy files ..."
cp "$SCRIPT" "$SCRIPT_PATH"
cp "$BROWSER" "$BROWSER_PATH"
cp "$ICON" "$ICON_PATH"
chmod +x "$SCRIPT_PATH"
chmod +x "$BROWSER_PATH"

# create desktop file
echo "Create desktop file ..."
printf "%s\n" \
    "[Desktop Entry]" \
    "Version=1.0" \
    "Type=Application" \
    "Name=Pluto" \
    "Comment=Julia Pluto Launcher" \
    "Exec=$BROWSER_PATH %F" \
    "Icon=$ICON_PATH" \
    "StartupWMClass=PlutoLauncher" \
    "Terminal=true" \
    "Categories=Development;Science;IDE;" \
    "MimeType=application/x-julia;text/x-julia;inode/directory;" \
    > "$DESKTOP_PATH"

# create systemd service
echo "Create systemd service ..."
mkdir -p "$HOME/.config/systemd/user"
printf "%s\n" \
    "[Unit]"\
    "Description=Pluto.jl Notebook Server"\
    "After=network.target"\
    ""\
    "[Service]"\
    "Type=simple"\
    "ExecStart=julia --project=$ENV_DIR --threads auto --startup-file=no $SCRIPT_PATH"\
    "Restart=on-failure"\
    ""\
    "[Install]"\
    "WantedBy=default.target"\
    > "$SERVICE_PATH"

# start systemd service
echo "Start systemd service ..."
systemctl --user daemon-reload
systemctl --user start pluto.service
systemctl --user enable pluto.service

# clean up
echo "Cleaning up ..."
cd ..
rm -rf "$TEMP_DIR"

echo "Installation complete!"
