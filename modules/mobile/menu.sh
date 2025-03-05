#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[mobile] Initializing mobile development tools menu..."

declare -A OPTIONS=(
  ["Android Studio"]="install-android-studio.sh"
  ["Flutter SDK"]="install-flutter.sh"
  ["React Native (JavaScript framework for mobile apps)"]="install-react-native.sh"
  ["Xamarin (C# framework for mobile apps)"]="install-xamarin.sh"
  ["Ionic (Cross-platform mobile app framework)"]="install-ionic.sh"
  ["Cordova (Mobile apps with HTML, CSS & JS)"]="install-cordova.sh"
)

# Get array of descriptions (keys)
DESCRIPTIONS=("${!OPTIONS[@]}")

# Display menu and get selections
log_info "[mobile] Displaying mobile tools selection menu..."
SELECTED=$(gum choose --no-limit \
    --header "Select mobile development tools to install (space to select, enter to confirm):" \
    "${DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED" ]; then
  log_warn "[mobile] No mobile tools selected; skipping installation."
  exit 0
fi

# Process and output selected script paths
log_info "[mobile] Processing selected mobile tool installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${OPTIONS[$SELECTION]}"
  log_info "[mobile] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED"

log_info "[mobile] Mobile tools selection complete."
