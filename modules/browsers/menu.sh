#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[browsers/menu] Launching browsers menu using Gum..."

options=(
  "install-chrome.sh"   "Google Chrome"
  "install-firefox.sh"  "Firefox"
  "install-brave.sh"    "Brave Browser"
)

selected=$(gum checkbox --title "Web Browsers" \
  --header "Select web browsers to install:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[browsers/menu] No browsers selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[browsers/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[browsers/menu] Browser installation complete."
