#!/bin/bash

# define paths
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
SCRIPT_NAME="pluto_launcher.jl"
SHELL_WRAPPER="pluto_launcher.sh"
INSTALL_PATH="$BIN_DIR/$SCRIPT_NAME"
WRAPPER_PATH="$BIN_DIR/$SHELL_WRAPPER"

# create folders
echo "Create folders ..." >&2
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"

# copy files
echo "Copy files ..."
cp "pluto.svg" "$APP_DIR/pluto.svg"
cp "$SCRIPT_NAME" "$INSTALL_PATH"
cp "$SHELL_WRAPPER" "$WRAPPER_PATH"
chmod +x "$INSTALL_PATH"
chmod +x "$WRAPPER_PATH"

# create desktop file
echo "Create Desktop entry ..."
cat <<EOF > "$APP_DIR/pluto_launcher.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Pluto Notebooks
Comment=Julia Pluto Launcher
Exec=$WRAPPER_PATH
Icon=$APP_DIR/pluto.svg
Terminal=false
Categories=Development;Science;IDE;
EOF

# find shell configuration (bash oder zsh)
shell_file=""
if [ -f "$HOME/.bashrc" ]; then
    shell_file="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    shell_file="$HOME/.zshrc"
fi

# add function to shell
if [ -n "$shell_file" ]; then
    # check, if function already exists
    if ! grep -q "source $WRAPPER_PATH" "$shell_file"; then
        echo -e "\n# Pluto Launcher\nsource $WRAPPER_PATH" >> "$shell_file"
    fi
fi

echo "Installation complete!"
