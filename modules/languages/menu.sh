#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[languages/menu] Launching language installation menu using Gum..."

options=(
  "install-python.sh" "Python 3 & pip"
  "install-node.sh"   "Node.js & npm"
  "install-ruby.sh"   "Ruby & Bundler"
  "install-go.sh"     "Golang"
  "install-rust.sh"   "Rust (via rustup)"
)

selected=$(gum checkbox --title "Language Modules" \
  --header "Select language installers to run:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[languages/menu] No selection made; skipping language installation."
  exit 0
fi

while IFS= read -r script; do
  log_info "[languages/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[languages/menu] Language installation complete."
