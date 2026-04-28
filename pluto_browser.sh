
function Pluto() {
    # Parameter 1: URL (optional)
    local BROWSER_URL="${1:-http://localhost:13254}"
    
    local BROWSER="chromium-browser"
    local BROWSER_ENV_DIR="$HOME/.local/share/pluto_env/browser"

    # start browser
    "$BROWSER" --app="$BROWSER_URL" \
               --user-data-dir="$BROWSER_ENV_DIR" \
               --class="PlutoLauncher" \
               --no-first-run &
}

# check for arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # get path from the first argument
    INPUT_PATH="$1"
    
    if [[ -n "$INPUT_PATH" ]]; then
        # change all "/" to "%2F"
        ENCODED_PATH="${INPUT_PATH//\//%2F}"
        
        FINAL_URL="http://localhost:13254/open?path=$ENCODED_PATH"
    else
        # Fallback
        FINAL_URL="http://localhost:13254"
    fi

    # call function
    Pluto "$FINAL_URL"
fi