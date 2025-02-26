#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[theme/menu] Launching GNOME theme installation menu using Gum..."

options=(
  "install-gnome-theme.sh" "Select a GNOME theme to install"
)

selected=$(gum checkbox --title "GNOME Themes" \
  --header "Select a theme option:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[theme/menu] No theme selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[theme/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[theme/menu] Theme installation complete."
