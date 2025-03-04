#!/usr/bin/env bash
#
# IDE & Code Editor Installation Menu
# ---------------------------------
# Interactive menu for installing popular IDEs and code editors
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ides] Initializing IDE installation menu..."

# Define available IDE options with descriptions
declare -A IDE_OPTIONS=(
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

IDE_DESCRIPTIONS=("${!IDE_OPTIONS[@]}")

# Display interactive selection menu
log_info "[ides] Displaying IDE selection menu..."
SELECTED_IDES=$(gum choose \
  --no-limit \
  --height 15 \
  --header "🖥️ IDE & Code Editor Installation" \
  --header.foreground="99" \
  --header "Select IDEs to install (space to select, enter to confirm):" \
  "${IDE_DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED_IDES" ]; then
  log_warn "[ides] No IDEs selected; skipping installation."
  exit 0
fi

# Process selected options
log_info "[ides] Processing selected IDE installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${IDE_OPTIONS[$SELECTION]}"
  log_info "[ides] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED_IDES"

log_info "[ides] IDE selection complete."
