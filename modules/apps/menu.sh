#!/usr/bin/env bash
#
# Apps Installation Menu
# -------------------
# Interactive menu for installing applications

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Initializing productivity apps installation menu..."

# Define available options with descriptions
declare -A OPTIONS=(
    ["Telegram (Secure messaging)"]="install-telegram.sh"
    ["WhatsApp (Messaging client)"]="install-whatsapp.sh"
    ["Discord (Voice, video, and text chat)"]="install-discord.sh"
    ["Slack (Team collaboration)"]="install-slack.sh"
    ["Spotify (Music streaming)"]="install-spotify.sh"
    ["VLC Media Player (Versatile media player)"]="install-vlc.sh"
    ["Bitwarden (Password manager)"]="install-bitwarden.sh"
    ["Ulauncher (Application launcher)"]="install-ulauncher.sh"
    ["Notion (All-in-one workspace)"]="install-notion.sh"
    ["Obsidian (Knowledge base & notes)"]="install-obsidian.sh"
    ["Dropbox (Cloud storage & sync)"]="install-dropbox.sh"
    ["Joplin (Note taking and to-do application)"]="install-joplin.sh"
    ["Postman (API development environment)"]="install-postman.sh"
    ["Zoom (Video conferencing)"]="install-zoom.sh"
)

# Get array of descriptions (keys)
DESCRIPTIONS=("${!OPTIONS[@]}")

# Display menu and get selections
log_info "[apps] Displaying productivity apps selection menu..."
SELECTED=$(gum choose --no-limit \
    --header "Select apps to install (space to select, enter to confirm):" \
    "${DESCRIPTIONS[@]}")

# Process and output selected script paths
log_info "[apps] Processing selected app installations..."
while IFS= read -r SELECTION; do
    if [ -n "$SELECTION" ]; then
        SCRIPT="apps/${OPTIONS[$SELECTION]}"
        log_info "[apps] Queuing: $SELECTION"
        echo "$SCRIPT"
    fi
done <<< "$SELECTED"

log_info "[apps] App selection complete."
