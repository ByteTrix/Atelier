#!/usr/bin/env bash
#
# CLI Tools Installation Menu
# -------------------------
# Interactive menu for installing command-line tools and utilities
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Initializing CLI tools installation menu..."

# Define available CLI tool options with descriptions
declare -A CLI_OPTIONS=(
  ["Fzf (Fuzzy finder for command line)"]="install-fzf.sh"
  ["Ripgrep (Fast regex-based search tool)"]="install-ripgrep.sh"
  ["Fd (Modern alternative to find)"]="install-fd.sh"
  ["Bat (Cat clone with syntax highlighting)"]="install-bat.sh"
  ["Eza [exa] (Modern replacement for ls)"]="install-exa.sh"
  ["Zoxide (Smarter cd command with tracking)"]="install-zoxide.sh"
  ["Ag (The Silver Searcher code search)"]="install-ag.sh"
  ["Tig (Text interface for Git)"]="install-tig.sh"
  ["Ncdu (Disk usage analyzer with ncurses)"]="install-ncdu.sh"
  ["Tree (Directory listing as tree)"]="install-tree.sh"
  ["LSD (LSDeluxe, modern ls alternative)"]="install-lsd.sh"
  ["Gum (Stylish shell script UI toolkit)"]="install-gum.sh"
  ["Ghostty (Modern GPU-accelerated terminal)"]="install-ghostty.sh"
  ["Jq (Command-line JSON processor)"]="install-jq.sh"
  ["Httpie (User-friendly HTTP client)"]="install-httpie.sh"
  ["Tmux (Terminal multiplexer)"]="install-tmux.sh"
  ["Neovim (Hyperextensible Vim-based text editor)"]="install-neovim.sh"
)

CLI_DESCRIPTIONS=("${!CLI_OPTIONS[@]}")

# Display interactive selection menu
log_info "[cli] Displaying CLI tools selection menu..."
SELECTED_TOOLS=$(gum choose \
  --no-limit \
  --height 20 \
  --header "🔧 Command Line Tools Installation" \
  --header.foreground="99" \
  --header "Select CLI tools to install (space to select, enter to confirm):" \
  "${CLI_DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED_TOOLS" ]; then
  log_warn "[cli] No CLI tools selected; skipping installation."
  exit 0
fi

# Process selected options
log_info "[cli] Processing selected CLI tool installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${CLI_OPTIONS[$SELECTION]}"
  log_info "[cli] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED_TOOLS"

log_info "[cli] CLI tools selection complete."
