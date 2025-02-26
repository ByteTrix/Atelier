#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[browsers/menu] Launching browsers installation menu using Gum..."

declare -A options=(
  ["Google Chrome"]="install-chrome.sh"
  ["Firefox"]="install-firefox.sh"
  ["Brave Browser"]="install-brave.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "Web Browsers" \
  --header "Select web browsers to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[browsers/menu] No browsers selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[browsers/menu] Selected: $desc -> $script"
  echo "$DIR/$script"
done <<< "$selected"
log_info "[browsers/menu] Browser installation complete."
