#!/bin/bash

# define paths
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
SCRIPT_NAME="pluto_launcher.jl"
INSTALL_PATH="$BIN_DIR/$SCRIPT_NAME"

# create folders
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"

# copy files
cp "pluto.svg" "$APP_DIR/pluto.svg"
cp "$SCRIPT_NAME" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

# create desktop file
cat <<EOF > "$APP_DIR/pluto_launcher.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Pluto Notebooks
Comment=Julia Pluto Launcher
Exec=julia --threads auto --startup-file=no --compile=min $INSTALL_PATH
Icon=$APP_DIR/pluto.svg
Terminal=true
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
    if ! grep -q "function Pluto()" "$shell_file"; then
        echo -e "\n# Pluto Launcher" >> "$shell_file"
        echo "function Pluto() {" >> "$shell_file"
        echo "    julia --threads auto --startup-file=no --compile=min $INSTALL_PATH \"\$@\"" >> "$shell_file"
        echo "}" >> "$shell_file"
        echo "Add 'Pluto' to $shell_file."
    fi
fi

echo "Installation complete!"
