#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[config/menu] Launching configuration menu using Gum..."

options=(
  "setup-dotfiles.sh"             "Setup dotfiles"
  "configure-vscode-keyring.sh"     "Configure VS Code keyring"
  "configure-gnome.sh"            "Configure GNOME settings"
)

selected=$(gum checkbox --title "System Configuration" \
  --header "Select configuration tasks to perform:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[config/menu] No configuration tasks selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[config/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[config/menu] Configuration tasks complete."
