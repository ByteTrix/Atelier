#!/usr/bin/env bash

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

# Check if gum is available
if ! command -v gum &> /dev/null; then
  log_error "[mobile] 'gum' command not found. Please install gum first."
  return 1
fi

# Display menu and get selections
log_info "[mobile] Displaying mobile tools selection menu..."
SELECTED=$(gum choose --no-limit \
    --header "Select mobile development tools to install (space to select, enter to confirm):" \
    "${DESCRIPTIONS[@]}") || {
    log_error "[mobile] Failed to display selection menu"
    return 1
  }

# Handle empty selection
if [ -z "$SELECTED" ]; then
  log_warn "[mobile] No mobile tools selected; skipping installation."
  return 0
fi

# Process and output selected script paths
log_info "[mobile] Processing selected mobile tool installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${OPTIONS[$SELECTION]}"
  SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT}"
  
  # Verify script exists
  if [ ! -f "$SCRIPT_PATH" ]; then
    log_error "[mobile] Installation script not found: $SCRIPT_PATH"
    continue
  fi
  
  # Verify script is executable
  if [ ! -x "$SCRIPT_PATH" ]; then
    log_error "[mobile] Installation script not executable: $SCRIPT_PATH"
    continue
  fi

  log_info "[mobile] Queuing: $SELECTION"
  echo "$SCRIPT_PATH"
done <<< "$SELECTED"

log_info "[mobile] Mobile tools selection complete."
