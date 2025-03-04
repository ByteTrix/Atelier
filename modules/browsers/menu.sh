#!/usr/bin/env bash
#
# Web Browsers Installation Menu
# --------------------------
# Interactive menu for installing web browsers

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[browsers] Initializing web browsers installation menu..."

# Define available options with descriptions
declare -A OPTIONS=(
    ["Google Chrome (Fast, popular browser)"]="install-chrome.sh"
    ["Firefox (Privacy-focused browser)"]="install-firefox.sh"
    ["Brave Browser (Privacy-first, ad-blocking)"]="install-brave.sh"
    ["Opera (Feature-rich, customizable browser)"]="install-opera.sh"
    ["Vivaldi (Highly customizable, privacy-focused)"]="install-vivaldi.sh"
    ["Edge (Microsoft's Chromium-based browser)"]="install-edge.sh"
)

# Get array of descriptions (keys)
DESCRIPTIONS=("${!OPTIONS[@]}")

# Display menu and get selections
log_info "[browsers] Displaying browser selection menu..."
SELECTED=$(gum choose --no-limit \
    --header "Select browsers to install (space to select, enter to confirm):" \
    "${DESCRIPTIONS[@]}")

# Process and output selected script paths
log_info "[browsers] Processing selected browser installations..."
while IFS= read -r SELECTION; do
    if [ -n "$SELECTION" ]; then
        SCRIPT="browsers/${OPTIONS[$SELECTION]}"
        log_info "[browsers] Queuing: $SELECTION"
        echo "$SCRIPT"
    fi
done <<< "$SELECTED"

log_info "[browsers] Browser selection complete."
