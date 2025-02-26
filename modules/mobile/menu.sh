#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[mobile/menu] Launching mobile development tools menu using Gum..."

options=(
  "install-android-studio.sh" "Android Studio"
  "install-flutter.sh"        "Flutter SDK"
)

selected=$(gum checkbox --title "Mobile Tools" \
  --header "Select mobile development tools to install:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[mobile/menu] No mobile tools selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[mobile/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[mobile/menu] Mobile tools installation complete."
