#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

# Check if we're running on GNOME
RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)
if ! $RUNNING_GNOME; then
    log_warn "Not running GNOME. Some options may not be available."
fi

# Display menu for theme selections
echo "Please select theme and appearance options:"

OPTIONS=(
    "${INSTALL_DIR}/modules/theme/install-gnome-theme.sh|GNOME Theme|Install the default GNOME theme package"
    "${INSTALL_DIR}/modules/theme/install-gnome-extensions.sh|GNOME Extensions|Install popular GNOME shell extensions"
    "${INSTALL_DIR}/modules/theme/configure-gnome-settings.sh|GNOME Settings|Configure recommended GNOME settings"
    "${INSTALL_DIR}/modules/theme/configure-gnome-extensions.sh|GNOME Extensions Config|Configure optimal settings for installed extensions"
    "${INSTALL_DIR}/modules/theme/install-icon-themes.sh|Icon Themes|Install additional icon themes"
    "${INSTALL_DIR}/modules/theme/install-cursor-themes.sh|Cursor Themes|Install additional cursor themes"
    "${INSTALL_DIR}/modules/theme/install-gtk-themes.sh|GTK Themes|Install additional GTK themes"
)

# Display options using gum and get selections
if ! command -v gum &>/dev/null; then
    log_error "This script requires gum to be installed"
    exit 1
fi

SELECTED=$(printf "%s\n" "${OPTIONS[@]}" | 
    gum choose --no-limit --height 15 --header "Select theme components to install:" --selected-prefix "✅" --unselected-prefix "[ ]" | 
    cut -d'|' -f1)

echo "$SELECTED"
