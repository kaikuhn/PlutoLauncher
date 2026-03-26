#!/bin/bash

function Pluto(){
    local ENV_DIR="$HOME/.pluto_launcher_env"
    local NOTEBOOK_DIR="$HOME/PlutoNotebooks"
    local BIN_DIR="$HOME/.local/bin"
    local SCRIPT_NAME="pluto_launcher.jl"
    local INSTALL_PATH="$BIN_DIR/$SCRIPT_NAME"

    # prepare directories
    mkdir -p "$ENV_DIR"
    mkdir -p "$NOTEBOOK_DIR"

    echo "Checking environment..."

    # prepare environment for Pluto
    julia --project="$ENV_DIR" -e '
        using Pkg;
        pkgs = ["Pluto", "ArgParse"];
        for p in pkgs
            if !haskey(Pkg.dependencies(), p)
                @info "Installing $p ..."
                Pkg.add(p)
            end
        end
    '

    # start pluto script
    julia --project="$ENV_DIR" --threads auto --startup-file=no "$INSTALL_PATH" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    Pluto "$@"
fi