#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[config] Applying GNOME desktop settings..."
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  gsettings set org.gnome.desktop.interface icon-theme "Papirus"
  gsettings set org.gnome.desktop.background show-desktop-icons false
  log_info "[config] GNOME desktop settings applied."
else
  log_warn "[config] gsettings not found; please configure GNOME manually."
fi
