#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[theme/menu] Launching GNOME theme installation menu using Gum..."

declare -A options=(
  ["Tokyo Night"]="install-gnome-theme.sh"  # You could add more options in your theme installer script.
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "GNOME Themes" \
  --header "Select a GNOME theme to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[theme/menu] No theme selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[theme/menu] Selected: $desc -> $script"
  echo "$DIR/$script"
done <<< "$selected"
log_info "[theme/menu] GNOME theme installation complete."
