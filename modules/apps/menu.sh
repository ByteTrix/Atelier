#!/usr/bin/env bash
#
# Productivity Apps Installation Menu
# --------------------------------
# Interactive menu for installing productivity and collaboration apps
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Initializing productivity apps installation menu..."

# Define available app options with descriptions
declare -A APP_OPTIONS=(
  ["Notion (All-in-one workspace)"]="install-notion.sh"
  ["Obsidian (Knowledge base & notes)"]="install-obsidian.sh"
  ["VLC Media Player (Versatile media player)"]="install-vlc.sh"
  ["Xournal++ (Note taking & PDF annotation)"]="install-xournal.sh"
  ["Localsend (Local network file sharing)"]="install-localsend.sh"
  ["WhatsApp (Messaging client)"]="install-whatsapp.sh"
  ["Spotify (Music streaming)"]="install-spotify.sh"
  ["Dropbox (Cloud storage & sync)"]="install-dropbox.sh"
  ["Todoist (Task management)"]="install-todoist.sh"
  ["Telegram (Secure messaging)"]="install-telegram.sh"
  ["Ulauncher (Application launcher)"]="install-ulauncher.sh"
  ["Syncthing (Decentralized file sync)"]="install-syncthing.sh"
)

APP_DESCRIPTIONS=("${!APP_OPTIONS[@]}")

# Display interactive selection menu
log_info "[apps] Displaying productivity apps selection menu..."
SELECTED_APPS=$(gum choose \
  --no-limit \
  --height 20 \
  --header "📱 Productivity & Collaboration Apps" \
  --header.foreground="99" \
  --header "Select apps to install (space to select, enter to confirm):" \
  "${APP_DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED_APPS" ]; then
  log_warn "[apps] No apps selected; skipping installation."
  exit 0
fi

# Process selected options
log_info "[apps] Processing selected app installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${APP_OPTIONS[$SELECTION]}"
  log_info "[apps] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED_APPS"

log_info "[apps] App selection complete."
