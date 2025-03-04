#!/usr/bin/env bash
#
# System Configuration Menu
# -----------------------
# Interactive menu for system configuration tasks
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[config] Initializing system configuration menu..."

# Define available configuration options with descriptions
declare -A CONFIG_OPTIONS=(
  ["Setup Dotfiles (Configure shell and environment)"]="setup-dotfiles.sh"
  ["Configure VS Code Keyring (Secure credential storage)"]="configure-vscode-keyring.sh"
)

CONFIG_DESCRIPTIONS=("${!CONFIG_OPTIONS[@]}")

# Display interactive selection menu
log_info "[config] Displaying configuration tasks menu..."
SELECTED_CONFIGS=$(gum choose \
  --no-limit \
  --height 15 \
  --header "⚙️ System Configuration" \
  --header.foreground="99" \
  --header "Select configuration tasks to perform (space to select, enter to confirm):" \
  "${CONFIG_DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED_CONFIGS" ]; then
  log_warn "[config] No configuration tasks selected; skipping."
  exit 0
fi

# Process selected options
log_info "[config] Processing selected configuration tasks..."
while IFS= read -r SELECTION; do
  SCRIPT="${CONFIG_OPTIONS[$SELECTION]}"
  log_info "[config] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED_CONFIGS"

log_info "[config] Configuration selection complete."
