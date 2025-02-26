#!/usr/bin/env bash
set -euo pipefail

# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source shared utilities.
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

# Create an array of descriptions.
descriptions=("${!options[@]}")

# Use Gum's choose command with --no-limit and --header.
selected=$(gum choose --no-limit --header "Select language installers to run:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[languages/menu] No selection made; skipping language installation."
  exit 0
fi

# For each selected description, output the full path of the corresponding script.
while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[languages/menu] Selected: $desc -> $script"
  echo "$DIR/$script"
done <<< "$selected"
