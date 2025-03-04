#!/usr/bin/env bash
#
# CLI Tools Installation Menu
# -----------------------
# Interactive menu for installing command-line tools

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Initializing CLI tools installation menu..."

# Define available options with descriptions
declare -A OPTIONS=(
    ["Ripgrep (Fast regex-based search tool)"]="install-ripgrep.sh"
    ["Bat (Cat clone with syntax highlighting)"]="install-bat.sh"
    ["Exa/Eza (Modern replacement for ls)"]="install-exa.sh"
    ["Zoxide (Smarter cd command)"]="install-zoxide.sh"
    ["Neovim (Hyperextensible text editor)"]="install-neovim.sh"
    ["Tmux (Terminal multiplexer)"]="install-tmux.sh"
    ["Tree (Directory listing)"]="install-tree.sh"
    ["Ncdu (Disk usage analyzer)"]="install-ncdu.sh"
    ["Ag (The Silver Searcher)"]="install-ag.sh"
    ["Fd (Modern alternative to find)"]="install-fd.sh"
    ["Jq (Command-line JSON processor)"]="install-jq.sh"
    ["LSD (LSDeluxe, modern ls alternative)"]="install-lsd.sh"
    ["Tig (Text interface for Git)"]="install-tig.sh"
    ["HTTPie (User-friendly HTTP client)"]="install-httpie.sh"
)

# Get array of descriptions (keys)
DESCRIPTIONS=("${!OPTIONS[@]}")

# Display menu and get selections
log_info "[cli] Displaying CLI tools selection menu..."
SELECTED=$(gum choose --no-limit \
    --header "Select command-line tools to install (space to select, enter to confirm):" \
    "${DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED" ]; then
  log_warn "[cli] No CLI tools selected; skipping installation."
  exit 0
fi

# Process and output selected script paths
log_info "[cli] Processing selected CLI tool installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${OPTIONS[$SELECTION]}"
  log_info "[cli] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED"

log_info "[cli] CLI tools selection complete."
