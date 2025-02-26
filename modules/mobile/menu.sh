#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[mobile/menu] Launching mobile development tools menu using Gum..."

declare -A options=(
  ["Android Studio"]="install-android-studio.sh"
  ["Flutter SDK"]="install-flutter.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "Mobile Tools" \
  --header "Select mobile development tools to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[mobile/menu] No mobile tools selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[mobile/menu] Selected: $desc -> $script"
  echo "$DIR/$script"
done <<< "$selected"
log_info "[mobile/menu] Mobile tools installation complete."
