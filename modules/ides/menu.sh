#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[ides/menu] Launching IDEs menu using Gum..."

options=(
  "install-vscode.sh"    "Visual Studio Code"
  "install-intellij.sh"  "IntelliJ IDEA CE"
  "install-emacs.sh"     "GNU Emacs"
  "install-geany.sh"     "Geany IDE"
)

selected=$(gum checkbox --title "IDEs & Editors" \
  --header "Select IDEs to install:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[ides/menu] No IDEs selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[ides/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[ides/menu] IDEs installation complete."
