#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli/menu] Launching CLI tools installation menu using Gum..."

options=(
  "install-fzf.sh"      "Fzf: Fuzzy finder"
  "install-ripgrep.sh"  "Ripgrep: Fast text search"
  "install-fd.sh"       "Fd: Improved file search"
  "install-bat.sh"      "Bat: cat with syntax highlighting"
  "install-exa.sh"      "Exa: Modern ls alternative"
  "install-zoxide.sh"   "Zoxide: Enhanced cd"
  "install-ag.sh"       "Ag: The Silver Searcher"
  "install-tig.sh"      "Tig: Git TUI"
  "install-ncdu.sh"     "Ncdu: Disk usage analyzer"
  "install-tree.sh"     "Tree: Directory tree view"
  "install-lsd.sh"      "LSD: Modern ls alternative"
)

selected=$(gum checkbox --title "CLI Tools" \
  --header "Select CLI tools to install:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[cli/menu] No CLI tools selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[cli/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[cli/menu] CLI tools installation complete."
