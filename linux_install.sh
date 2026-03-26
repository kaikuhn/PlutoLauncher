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
    echo "Julia is already installed. OK ..."
else
    echo "Julia will be installed ..."
    curl -fsSL https://install.julialang.org | sh -s -- -y

    echo "Installation completed!"
    echo "Please restart the shell and start the Installation script again!"
    exit 0
fi

# Preapare Julia environment for Pluto
echo "Checking environment..."
ENV_DIR="$HOME/.pluto_launcher_env"
mkdir -p "$ENV_DIR"

julia --project="$ENV_DIR" -e '
    using Pkg;
    pkgs = ["Pluto", "ArgParse", "Electron"];
    for p in pkgs
        if !haskey(Pkg.dependencies(), p)
            @info "Installing $p ..."
            Pkg.add(p)
        end
    end
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

# define paths
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
SCRIPT="pluto.jl"
WRAPPER="pluto_wrapper.sh"
DESKTOP="pluto.desktop"
ICON="pluto.svg"
SCRIPT_PATH="$BIN_DIR/$SCRIPT"
WRAPPER_PATH="$BIN_DIR/$WRAPPER"
DESKTOP_PATH="$APP_DIR/$DESKTOP"
ICON_PATH="$ICON_DIR/$ICON"

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
printf "%s\n" \
    "[Desktop Entry]" \
    "Version=1.0" \
    "Type=Application" \
    "Name=Pluto" \
    "Comment=Julia Pluto Launcher" \
    "Exec=$WRAPPER_PATH %F" \
    "Icon=$ICON_PATH" \
    "StartupWMClass=PlutoLauncher" \
    "Terminal=true" \
    "Categories=Development;Science;IDE;" \
    "MimeType=application/x-julia;text/x-julia;inode/directory;" \
    > "$DESKTOP_PATH"

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
