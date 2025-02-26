#!/usr/bin/env bash
set -euo pipefail

# Determine the directory of this script.
DIR="$(dirname "$(realpath "$0")")"
# Source shared utilities from the repository root.
source "$DIR/../../lib/utils.sh"

# Use Gum to prompt the user for a Yes/No choice.
selected=$(gum choose --header "Do you want to install a GNOME theme?" "Yes" "No")

if [[ "$selected" == "Yes" ]]; then
  log_info "[theme/menu] User selected to install a GNOME theme."
  # Output the full path of the GNOME theme installation script.
  echo "$DIR/install-gnome-theme.sh"
else
  log_info "[theme/menu] User selected not to install a GNOME theme."
fi

log_info "[theme/menu] GNOME theme installation menu complete."
