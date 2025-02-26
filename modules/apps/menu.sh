#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[apps/menu] Launching productivity apps menu using Gum..."

options=(
  "install-notion.sh"      "Notion"
  "install-obsidian.sh"    "Obsidian"
  "install-vlc.sh"         "VLC Media Player"
  "install-xournal.sh"     "Xournal++"
  "install-localsend.sh"   "Localsend"
  "install-whatsapp.sh"    "WhatsApp"
  "install-spotify.sh"     "Spotify"
  "install-dropbox.sh"     "Dropbox"
  "install-todoist.sh"     "Todoist"
  "install-telegram.sh"    "Telegram"
  "install-ulauncher.sh"   "Ulauncher"
  "install-syncthing.sh"   "Syncthing"
)

selected=$(gum checkbox --title "Productivity & Collaboration Apps" \
  --header "Select apps to install:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[apps/menu] No apps selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[apps/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[apps/menu] Apps installation complete."
