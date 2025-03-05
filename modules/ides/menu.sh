#!/usr/bin/env bash
#
# IDE & Code Editor Installation Menu
# ---------------------------------
# Interactive menu for installing popular IDEs and code editors
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if gum is available
if ! command -v gum &>/dev/null; then
    log_error "[ides] This menu requires 'gum' to be installed"
    return 1
fi

log_info "[ides] Initializing IDE installation menu..."

# Define available IDE options with descriptions
declare -A OPTIONS=(
  ["Visual Studio Code (Modern, extensible editor)"]="install-vscode.sh"
  ["IntelliJ IDEA CE (Java & JVM languages IDE)"]="install-intellij.sh"
  ["GNU Emacs (Extensible, customizable editor)"]="install-emacs.sh"
  ["Geany IDE (Lightweight, fast IDE)"]="install-geany.sh"
  ["PyCharm (Python IDE)"]="install-pycharm.sh"
  ["Eclipse (Java IDE)"]="install-eclipse.sh"
  ["NetBeans (Java IDE)"]="install-netbeans.sh"
  ["Sublime Text (Text editor for code, markup, and prose)"]="install-sublime.sh"
  ["Atom (Hackable text editor)"]="install-atom.sh"
  ["Vim (Highly configurable text editor)"]="install-vim.sh"
)

# Get array of descriptions (keys)
DESCRIPTIONS=("${!OPTIONS[@]}")

# Display interactive selection menu
log_info "[ides] Displaying IDE selection menu..."
SELECTED=$(gum choose \
  --no-limit \
  --height 15 \
  --header "🖥️ IDE & Code Editor Installation" \
  --header.foreground="99" \
  --header "Select IDEs to install (space to select, enter to confirm):" \
  "${DESCRIPTIONS[@]}") || {
    log_error "[ides] Menu selection failed"
    return 1
}

# Handle empty selection
if [ -z "$SELECTED" ]; then
    log_warn "[ides] No IDEs selected; skipping installation."
    return 0
fi

# Process selected options
log_info "[ides] Processing selected IDE installations..."
while IFS= read -r SELECTION; do
    # Verify the selection exists in OPTIONS
    if [ -z "${OPTIONS[$SELECTION]:-}" ]; then
        log_error "[ides] Invalid selection: $SELECTION"
        continue
    fi

    SCRIPT="${OPTIONS[$SELECTION]}"
    SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT}"

    # Verify script exists
    if [ ! -f "$SCRIPT_PATH" ]; then
        log_error "[ides] Installation script not found: $SCRIPT"
        continue
    fi

    log_info "[ides] Queuing: $SELECTION"
    echo "$SCRIPT_PATH"
done <<< "$SELECTED"

log_success "[ides] IDE selection complete"
return 0
