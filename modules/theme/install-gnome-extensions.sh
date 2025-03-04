#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

# Check if GNOME is running
if [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
    log_warn "GNOME is not running, skipping GNOME extensions installation"
    exit 0
fi

log_info "Installing GNOME Extensions..."

# Install GNOME Shell Extensions
sudo apt install -y gnome-shell-extensions chrome-gnome-shell gnome-tweaks

# Install GNOME Shell Extension manager
sudo apt install -y gnome-shell-extension-manager

# Define user's preferred extensions to install
EXTENSIONS=(
    "AlphabeticalAppGrid@stuarthayhurst"              # Alphabetical App Grid
    "bluetooth-quick-connect@bjarosze.gmail.com"      # Bluetooth Quick Connect
    "blur-my-shell@aunetx"                            # Blur My Shell
    "burn-my-windows@schneegans.github.com"           # Burn My Windows
    "clipboard-indicator@tudmotu.com"                 # Clipboard Indicator
    "compiz-alike-magic-lamp-effect@hermes83.github.com" # Compiz Alike Magic Lamp Effect
    "CoverflowAltTab@palatis.blogspot.com"            # Coverflow Alt-Tab
    "dash-to-dock@micxgx.gmail.com"                   # Dash to Dock
    "space-bar@luchrioh"                              # Space Bar
    "tactile@lundal"                                  # Tactile
    "TopHat@fflewddur.github.io"                      # TopHat
    "undecoratex@lennart.github.io"                   # Undecorate Window
)

# Define system extensions to disable
SYSTEM_EXTENSIONS=(
    "ding@rastersoft.com"                             # DING (Desktop Icons NG)
    "appindicatorsupport@rgcjonas.gmail.com"          # Ubuntu AppIndicators
    "ubuntu-dock@ubuntu.com"                          # Ubuntu Dock
    "ubuntu-tiling-assistant@ubuntu.com"              # Ubuntu Tiling Assistant
)

# Install extensions using extension manager (if available)
log_info "Installing user-preferred GNOME extensions..."
for ext in "${EXTENSIONS[@]}"; do
    extension_name=${ext%%@*}
    log_info "Installing extension: $extension_name"
    
    if gnome-extensions info "$ext" &>/dev/null; then
        log_info "$ext is already installed"
    else
        log_info "Installing $ext via extension manager"
        if command -v gnome-extensions-app &>/dev/null; then
            gnome-extensions-app --install-extension="$ext" || log_warn "Could not install $ext using extension manager"
        else
            log_warn "gnome-extensions-app not available, skipping $ext installation"
        fi
    fi
done

# Enable user-preferred extensions
log_info "Enabling user-preferred extensions..."
for ext in "${EXTENSIONS[@]}"; do
    if gnome-extensions info "$ext" &>/dev/null; then
        log_info "Enabling $ext"
        gnome-extensions enable "$ext" || log_warn "Could not enable $ext"
    else
        log_warn "$ext is not installed, skipping activation"
    fi
done

# Disable system extensions
log_info "Disabling system extensions..."
for ext in "${SYSTEM_EXTENSIONS[@]}"; do
    if gnome-extensions info "$ext" &>/dev/null; then
        log_info "Disabling $ext"
        gnome-extensions disable "$ext" || log_warn "Could not disable $ext"
    else
        log_info "$ext is not installed or already disabled"
    fi
done

# Install extensions via browser method if needed
log_info "Some extensions might require manual installation through the GNOME Extensions website"
log_info "Please visit: https://extensions.gnome.org/ to install any missing extensions"

log_info "GNOME Extensions setup completed."

