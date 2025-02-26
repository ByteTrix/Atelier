#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[config/menu] Launching system configuration menu using Gum..."

declare -A options=(
  ["Setup Dotfiles (Beta)"]="setup-dotfiles.sh"
  ["Configure VS Code Keyring"]="configure-vscode-keyring.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "System Configuration" \
  --header "Select configuration tasks to perform:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[config/menu] No configuration tasks selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[config/menu] Selected: $desc -> $script"
  echo "$DIR/$script"
done <<< "$selected"
log_info "[config/menu] Configuration tasks complete."
