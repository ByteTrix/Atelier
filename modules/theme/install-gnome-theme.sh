#!/usr/bin/env bash
set -euo pipefail
# Source shared utilities from the repository.
source ~/.local/share/Setupr/lib/utils.sh

log_info "[theme] Launching GNOME Theme Installer using Gum..."

# Use Gum to present theme options.
theme_choice=$(gum choose "Tokyo Night" "Catppuccin" "Nord" --header "Select a GNOME theme to install:")

case "$theme_choice" in
  "Tokyo Night")
    THEME_NAME="TokyoNight"
    REPO_URL="https://github.com/EliverLara/TokyoNight-GTK.git"
    ;;
  "Catppuccin")
    THEME_NAME="Catppuccin"
    REPO_URL="https://github.com/catppuccin/gtk.git"
    ;;
  "Nord")
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
  update_choice=$(gum choose "Yes" "No" --header "Do you want to update it?")
  if [[ "$update_choice" == "Yes" ]]; then
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
