#!/usr/bin/env bash
#
# Web Browsers Installation Menu
# ---------------------------
# Interactive menu for installing web browsers
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[browsers] Initializing web browsers installation menu..."

# Define available browser options with descriptions
declare -A BROWSER_OPTIONS=(
  ["Google Chrome (Fast, popular browser)"]="install-chrome.sh"
  ["Firefox (Privacy-focused browser)"]="install-firefox.sh"
  ["Brave Browser (Privacy-first, ad-blocking)"]="install-brave.sh"
  ["Zen Browser (Minimalist, distraction-free)"]="install-zen.sh"
  ["Opera (Feature-rich, customizable browser)"]="install-opera.sh"
  ["Vivaldi (Highly customizable, privacy-focused)"]="install-vivaldi.sh"
  ["Edge (Microsoft's Chromium-based browser)"]="install-edge.sh"
)

BROWSER_DESCRIPTIONS=("${!BROWSER_OPTIONS[@]}")

# Display interactive selection menu
log_info "[browsers] Displaying browser selection menu..."
SELECTED_BROWSERS=$(gum choose \
  --no-limit \
  --height 15 \
  --header "🌐 Web Browsers Installation" \
  --header.foreground="99" \
  --header "Select browsers to install (space to select, enter to confirm):" \
  "${BROWSER_DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED_BROWSERS" ]; then
  log_warn "[browsers] No browsers selected; skipping installation."
  exit 0
fi

# Process selected options
log_info "[browsers] Processing selected browser installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${BROWSER_OPTIONS[$SELECTION]}"
  log_info "[browsers] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED_BROWSERS"

log_info "[browsers] Browser selection complete."
