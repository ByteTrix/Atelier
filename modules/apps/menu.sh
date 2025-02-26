#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[apps/menu] Launching productivity apps menu using Gum..."

declare -A options=(
  ["Notion"]="install-notion.sh"
  ["Obsidian"]="install-obsidian.sh"
  ["VLC Media Player"]="install-vlc.sh"
  ["Xournal++"]="install-xournal.sh"
  ["Localsend"]="install-localsend.sh"
  ["WhatsApp"]="install-whatsapp.sh"
  ["Spotify"]="install-spotify.sh"
  ["Dropbox"]="install-dropbox.sh"
  ["Todoist"]="install-todoist.sh"
  ["Telegram"]="install-telegram.sh"
  ["Ulauncher"]="install-ulauncher.sh"
  ["Syncthing"]="install-syncthing.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "Productivity & Collaboration Apps" \
  --header "Select apps to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[apps/menu] No apps selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[apps/menu] Executing $script for '$desc'..."
  bash "$DIR/$script"
done <<< "$selected"

log_info "[apps/menu] Apps installation complete."
