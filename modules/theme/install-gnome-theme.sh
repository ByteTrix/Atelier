#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

echo "============================================"
echo "         GNOME Theme Installer"
echo "============================================"
echo ""
echo "Select a theme to install:"
echo "  1) Tokyo Night"
echo "  2) Catppuccin"
echo "  3) Nord"
echo ""
read -rp "Enter your choice (1-3): " theme_choice

case "$theme_choice" in
  1)
    THEME_NAME="TokyoNight"
    REPO_URL="https://github.com/EliverLara/TokyoNight-GTK.git"
    ;;
  2)
    THEME_NAME="Catppuccin"
    REPO_URL="https://github.com/catppuccin/gtk.git"
    ;;
  3)
    THEME_NAME="Nord"
    REPO_URL="https://github.com/arcticicestudio/nord-gtk-theme.git"
    ;;
  *)
    log_error "Invalid choice. Exiting."
    exit 1
    ;;
esac

THEME_DIR="/usr/share/themes"

log_info "[theme] Installing the $THEME_NAME theme..."
if [ ! -d "${THEME_DIR}/${THEME_NAME}" ]; then
  git clone "$REPO_URL" "${THEME_DIR}/${THEME_NAME}"
else
  log_warn "[theme] $THEME_NAME theme is already installed."
  read -rp "Do you want to update it? (y/n): " update_choice
  if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    cd "${THEME_DIR}/${THEME_NAME}" && git pull && cd - >/dev/null
  fi
fi

if command -v gsettings &>/dev/null; then
  log_info "[theme] Applying GNOME theme: $THEME_NAME..."
  gsettings set org.gnome.desktop.interface gtk-theme "${THEME_NAME}"
  gsettings set org.gnome.desktop.wm.preferences theme "${THEME_NAME}"
else
  log_warn "[theme] gsettings not found; please apply the theme manually."
fi

log_info "[theme] GNOME theme installation complete."
