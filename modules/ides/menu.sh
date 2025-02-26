#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[ides/menu] Launching IDEs installation menu using Gum..."

declare -A options=(
  ["Visual Studio Code"]="install-vscode.sh"
  ["IntelliJ IDEA CE"]="install-intellij.sh"
  ["GNU Emacs"]="install-emacs.sh"
  ["Geany IDE"]="install-geany.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "IDEs & Editors" \
  --header "Select IDEs to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[ides/menu] No IDEs selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[ides/menu] Executing $script for '$desc'..."
  bash "$DIR/$script"
done <<< "$selected"

log_info "[ides/menu] IDE installation complete."
