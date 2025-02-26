#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[cli/menu] Launching CLI tools installation menu using Gum..."

declare -A options=(
  ["Fzf (Fuzzy Finder)"]="install-fzf.sh"
  ["Ripgrep (Fast text search)"]="install-ripgrep.sh"
  ["Fd (Improved file search)"]="install-fd.sh"
  ["Bat (Enhanced cat)"]="install-bat.sh"
  ["Exa (Modern ls)"]="install-exa.sh"
  ["Zoxide (Enhanced cd)"]="install-zoxide.sh"
  ["Ag (The Silver Searcher)"]="install-ag.sh"
  ["Tig (Git TUI)"]="install-tig.sh"
  ["Ncdu (Disk usage analyzer)"]="install-ncdu.sh"
  ["Tree (Directory tree view)"]="install-tree.sh"
  ["LSD (Modern ls alternative)"]="install-lsd.sh"
  ["Gum (Interactive UI)"]="install-gum.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "CLI Tools" \
  --header "Select CLI tools to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[cli/menu] No CLI tools selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[cli/menu] Executing $script for '$desc'..."
  bash "$DIR/$script"
done <<< "$selected"

log_info "[cli/menu] CLI tools installation complete."
