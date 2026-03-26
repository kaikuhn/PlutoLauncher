#!/bin/bash

echo "find shell configuration (bash oder zsh) ..."
shell_file=""
if [ -f "$HOME/.bashrc" ]; then
    shell_file="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    shell_file="$HOME/.zshrc"
else
    echo "ERROR: Neither ~/.bashrc nor ~/.zshrc was found. Please check your shell configuration."
    exit 1
fi

# Install Julia, if necessary
if command -v julia &> /dev/null; then
    echo "Julia already installed"
elif
    echo "Julia needs to be installed ..."
    curl -fsSL https://install.julialang.org | sh -s -- -y
    source "$shell_file"
fi

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
SCRIPT="pluto_launcher.jl"
WRAPPER="pluto_launcher.sh"
DESKTOP="pluto.desktop"
ICON="pluto.svg"
SCRIPT_PATH="$BIN_DIR/$SCRIPT"
WRAPPER_PATH="$BIN_DIR/$WRAPPER"
DESKTOP_PATH="$APP_DIR/$DESKTOP"
ICON_PATH="$APP_DIR/$ICON"

# create folders
echo "Create folders ..."
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"

# copy files
echo "Copy files ..."
cp "$SCRIPT" "$SCRIPT_PATH"
cp "$WRAPPER" "$WRAPPER_PATH"
cp "$ICON" "$ICON_PATH"
chmod +x "$SCRIPT_PATH"
chmod +x "$WRAPPER_PATH"

# create desktop file
echo "Create Desktop entry ..."
cat <<EOF > "$DESKTOP_PATH"
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Pluto Notebooks
    Comment=Julia Pluto Launcher
    Exec=$WRAPPER_PATH
    Icon=$ICON_Path -d=%U
    Terminal=false
    Categories=Development;Science;IDE;
    MimeType=inode/directory;
EOF

# add function to shell
echo "Add Pluto to shell ..."
if [ -n "$shell_file" ]; then
    # check, if function already exists
    if ! grep -q "source $WRAPPER_PATH" "$shell_file"; then
        echo -e "\n# Pluto Launcher\nsource $WRAPPER_PATH" >> "$shell_file"
    fi
fi

# clean up
echo "Cleaning up ..."
cd ..
rm -rf "$TEMP_DIR"

echo "Installation complete!"
