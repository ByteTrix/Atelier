#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

# Check if GNOME is running
if [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
    log_warn "GNOME is not running, skipping GNOME settings configuration"
    exit 0
fi

log_info "Configuring GNOME settings..."

# Function to set a GNOME setting
set_gsetting() {
    local schema="$1"
    local key="$2"
    local value="$3"
    
    if gsettings set "$schema" "$key" "$value"; then
        log_info "Set $schema $key to $value"
    else
        log_warn "Failed to set $schema $key to $value"
    fi
}

# Appearance settings
log_info "Configuring appearance settings..."
set_gsetting "org.gnome.desktop.interface" "color-scheme" "'prefer-dark'"
set_gsetting "org.gnome.desktop.interface" "gtk-theme" "'Adwaita-dark'"
set_gsetting "org.gnome.desktop.interface" "icon-theme" "'Adwaita'"
set_gsetting "org.gnome.desktop.interface" "cursor-theme" "'Adwaita'"
set_gsetting "org.gnome.desktop.interface" "font-name" "'Ubuntu 11'"
set_gsetting "org.gnome.desktop.interface" "monospace-font-name" "'Ubuntu Mono 13'"
set_gsetting "org.gnome.desktop.interface" "document-font-name" "'Sans 11'"

# Workspace settings
log_info "Configuring workspace settings..."
set_gsetting "org.gnome.mutter" "dynamic-workspaces" "true"
set_gsetting "org.gnome.desktop.wm.preferences" "workspace-names" "['Main', 'Web', 'Code', 'Terminal']"
set_gsetting "org.gnome.shell.app-switcher" "current-workspace-only" "true"

# Window management
log_info "Configuring window management..."
set_gsetting "org.gnome.desktop.wm.preferences" "button-layout" "'appmenu:minimize,maximize,close'"
set_gsetting "org.gnome.desktop.wm.preferences" "focus-mode" "'click'"
set_gsetting "org.gnome.mutter" "center-new-windows" "true"

# Power settings
log_info "Configuring power settings..."
set_gsetting "org.gnome.settings-daemon.plugins.power" "sleep-inactive-ac-type" "'nothing'"
set_gsetting "org.gnome.settings-daemon.plugins.power" "power-button-action" "'interactive'"

# Privacy settings
log_info "Configuring privacy settings..."
set_gsetting "org.gnome.desktop.privacy" "remember-recent-files" "false"
set_gsetting "org.gnome.desktop.privacy" "remove-old-temp-files" "true"
set_gsetting "org.gnome.desktop.privacy" "remove-old-trash-files" "true"
set_gsetting "org.gnome.desktop.privacy" "old-files-age" "7"


log_info "GNOME settings configured successfully"
