#!/usr/bin/env bash
set -euo pipefail

# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source shared utilities from the repository root.
source "$DIR/../../lib/utils.sh"

log_info "[languages/menu] Launching language installation menu using Gum..."

# Define an associative array mapping descriptions to script filenames.
declare -A options=(
  ["Python 3 & pip"]="install-python.sh"
  ["Node.js & npm"]="install-node.sh"
  ["Ruby & Bundler"]="install-ruby.sh"
  ["Golang"]="install-go.sh"
  ["Rust (via rustup)"]="install-rust.sh"
)

# Create an array of descriptions (keys of the associative array).
descriptions=("${!options[@]}")

# Use Gum's choose command to allow multiple selections.
selected=$(gum choose --no-limit --header "Language Modules" \
  --header "Select language installers to run:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[languages/menu] No selection made; skipping language installation."
  exit 0
fi

# Process each selected option.
while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[languages/menu] Executing $script for '$desc'..."
  bash "$DIR/$script"
done <<< "$selected"

log_info "[languages/menu] Language installation complete."
