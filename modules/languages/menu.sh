#!/usr/bin/env bash
#
# Programming Languages Installation Menu
# --------------------------------------
# Interactive menu for installing various programming languages
# and their associated package managers.
#
# Author: Atelier Team
# License: MIT

# Determine the directory of the current script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Source shared utilities
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[languages] Initializing language installation menu..."

# Define available language options with descriptions and installation scripts
declare -A OPTIONS=(
  ["Python 3 & pip (Fast, versatile language)"]="install-python.sh"
  ["Node.js & npm (JavaScript runtime)"]="install-node.sh"
  ["Ruby & Bundler (Elegant language)"]="install-ruby.sh"
  ["Golang (Fast, statically typed language)"]="install-go.sh"
  ["Rust (Memory-safe systems language)"]="install-rust.sh"
  ["Java (Popular, high-level programming language)"]="install-java.sh"
  ["PHP (Server-side scripting language)"]="install-php.sh"
  ["Perl (High-level, general-purpose language)"]="install-perl.sh"
  ["Swift (Powerful and intuitive language for iOS/macOS)"]="install-swift.sh"
  ["Kotlin (Modern, concise language for JVM and Android)"]="install-kotlin.sh"
)

# Extract descriptions for gum menu
DESCRIPTIONS=("${!OPTIONS[@]}")

# Display interactive selection menu with clear instructions
log_info "[languages] Displaying language selection menu..."

if ! command -v gum &> /dev/null; then
  log_error "[languages] 'gum' command not found. Please install gum first."
  return 1
fi

SELECTED=$(gum choose \
  --no-limit \
  --height 15 \
  --header "💻 Programming Language Installation" \
  --header.foreground="99" \
  --header "Select languages to install (space to select, enter to confirm):" \
  "${DESCRIPTIONS[@]}") || {
    log_error "[languages] Failed to display selection menu"
    return 1
  }

# Handle empty selection gracefully
if [ -z "$SELECTED" ]; then
  log_warn "[languages] No languages selected; skipping installation."
  return 0
fi

# Process selected options
log_info "[languages] Processing selected language installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${OPTIONS[$SELECTION]}"
  SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT}"
  
  # Verify script exists
  if [ ! -f "$SCRIPT_PATH" ]; then
    log_error "[languages] Installation script not found: $SCRIPT_PATH"
    continue
  fi
  
  # Verify script is executable
  if [ ! -x "$SCRIPT_PATH" ]; then
    log_error "[languages] Installation script not executable: $SCRIPT_PATH"
    continue
  fi

  log_info "[languages] Queuing: $SELECTION"
  echo "$SCRIPT_PATH"
done <<< "$SELECTED"

log_info "[languages] Language selection complete."
