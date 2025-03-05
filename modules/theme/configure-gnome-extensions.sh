#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

# Check if GNOME is running
if [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
    log_warn "GNOME is not running, skipping GNOME extensions configuration"
    exit 0
fi

log_info "Configuring GNOME extensions..."

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

# Function to check if extension is installed
is_extension_installed() {
    local ext="$1"
    gnome-extensions info "$ext" &>/dev/null
}

# Configure AlphabeticalAppGrid
if is_extension_installed "AlphabeticalAppGrid@stuarthayhurst"; then
    log_info "Configuring Alphabetical App Grid..."
    set_gsetting "org.gnome.shell.extensions.alphabetical-app-grid" "folder-order-position" "'start'"
    set_gsetting "org.gnome.shell.extensions.alphabetical-app-grid" "sort-folders" "true"
fi

# Configure Bluetooth Quick Connect
if is_extension_installed "bluetooth-quick-connect@bjarosze.gmail.com"; then
    log_info "Configuring Bluetooth Quick Connect..."
    set_gsetting "org.gnome.shell.extensions.bluetooth-quick-connect" "show-battery-icon-on" "true"
    set_gsetting "org.gnome.shell.extensions.bluetooth-quick-connect" "show-battery-value-on" "true"
fi

# Configure Blur My Shell
if is_extension_installed "blur-my-shell@aunetx"; then
    log_info "Configuring Blur My Shell..."
    set_gsetting "org.gnome.shell.extensions.blur-my-shell" "sigma" "30"
    set_gsetting "org.gnome.shell.extensions.blur-my-shell" "brightness" "0.6"
    
    # Panel configuration
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.panel" "blur" "true"
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.panel" "static-blur" "true"
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.panel" "style-panel" "2"
    
    # Overview configuration
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.overview" "blur" "true"
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.overview" "style-components" "2"
    
    # Dash configuration
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.applications" "blur" "true"
    set_gsetting "org.gnome.shell.extensions.blur-my-shell.applications" "opacity" "230"
fi

# Configure Burn My Windows
if is_extension_installed "burn-my-windows@schneegans.github.com"; then
    log_info "Configuring Burn My Windows..."
    set_gsetting "org.gnome.shell.extensions.burn-my-windows" "active-profile" "'Default'"
    set_gsetting "org.gnome.shell.extensions.burn-my-windows" "close-animation" "'TV'"
    set_gsetting "org.gnome.shell.extensions.burn-my-windows" "open-animation" "'Fire'"
    set_gsetting "org.gnome.shell.extensions.burn-my-windows.profile-0" "tv-animation-time" "750"
    set_gsetting "org.gnome.shell.extensions.burn-my-windows.profile-0" "fire-animation-time" "750"
fi

# Configure Clipboard Indicator
if is_extension_installed "clipboard-indicator@tudmotu.com"; then
    log_info "Configuring Clipboard Indicator..."
    set_gsetting "org.gnome.shell.extensions.clipboard-indicator" "history-size" "50"
    set_gsetting "org.gnome.shell.extensions.clipboard-indicator" "move-item-first" "true"
    set_gsetting "org.gnome.shell.extensions.clipboard-indicator" "preview-size" "40"
    set_gsetting "org.gnome.shell.extensions.clipboard-indicator" "strip-text" "false"
    set_gsetting "org.gnome.shell.extensions.clipboard-indicator" "display-mode" "0"
fi

# Configure Compiz Alike Magic Lamp Effect
if is_extension_installed "compiz-alike-magic-lamp-effect@hermes83.github.com"; then
    log_info "Configuring Compiz Alike Magic Lamp Effect..."
    set_gsetting "org.gnome.shell.extensions.compiz-alike-magic-lamp" "duration" "400"
    set_gsetting "org.gnome.shell.extensions.compiz-alike-magic-lamp" "x-tiles" "9"
    set_gsetting "org.gnome.shell.extensions.compiz-alike-magic-lamp" "y-tiles" "9"
fi

# Configure CoverflowAltTab
if is_extension_installed "CoverflowAltTab@palatis.blogspot.com"; then
    log_info "Configuring CoverflowAltTab..."
    set_gsetting "org.gnome.shell.extensions.coverflowalttab" "animation-time" "0.25"
    set_gsetting "org.gnome.shell.extensions.coverflowalttab" "switcher-style" "'Coverflow'"
    set_gsetting "org.gnome.shell.extensions.coverflowalttab" "enforce-primary-monitor" "true"
    set_gsetting "org.gnome.shell.extensions.coverflowalttab" "position" "'Top'"
    set_gsetting "org.gnome.shell.extensions.coverflowalttab" "icon-style" "'Overlay'"
fi

# Configure Dash to Dock
if is_extension_installed "dash-to-dock@micxgx.gmail.com"; then
    log_info "Configuring Dash to Dock..."
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dock-position" "'BOTTOM'"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "extend-height" "false"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "transparency-mode" "'DYNAMIC'"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "custom-theme-shrink" "true"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "background-opacity" "0.4"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dash-max-icon-size" "48"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "show-apps-at-top" "false"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "scroll-action" "'switch-workspace'"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "autohide" "true"
    set_gsetting "org.gnome.shell.extensions.dash-to-dock" "intellihide" "true"
fi

# Configure Space Bar
if is_extension_installed "space-bar@luchrioh"; then
    log_info "Configuring Space Bar..."
    set_gsetting "org.gnome.shell.extensions.space-bar" "position" "'top'"
    set_gsetting "org.gnome.shell.extensions.space-bar" "position-index" "0"
    set_gsetting "org.gnome.shell.extensions.space-bar" "workspace-indicator" "'number'"
    set_gsetting "org.gnome.shell.extensions.space-bar" "show-empty-workspaces" "false"
    set_gsetting "org.gnome.shell.extensions.space-bar" "show-favorites" "true"
    set_gsetting "org.gnome.shell.extensions.space-bar" "scroll-wheel" "'switch-workspace'"
fi

# Configure Tactile
if is_extension_installed "tactile@lundal"; then
    log_info "Configuring Tactile..."
    set_gsetting "org.gnome.shell.extensions.tactile" "gap" "5"
    set_gsetting "org.gnome.shell.extensions.tactile" "split-delay" "500"
fi

# Configure TopHat
if is_extension_installed "TopHat@fflewddur.github.io"; then
    log_info "Configuring TopHat..."
    set_gsetting "org.gnome.shell.extensions.tophat" "cpu-display" "true"
    set_gsetting "org.gnome.shell.extensions.tophat" "memory-display" "true"
    set_gsetting "org.gnome.shell.extensions.tophat" "show-animation" "true"
    set_gsetting "org.gnome.shell.extensions.tophat" "indicator-position" "'left'"
    set_gsetting "org.gnome.shell.extensions.tophat" "refresh-rate" "1"
    set_gsetting "org.gnome.shell.extensions.tophat" "processor-show-cores" "false"
    set_gsetting "org.gnome.shell.extensions.tophat" "disk-display" "false"
    set_gsetting "org.gnome.shell.extensions.tophat" "network-display" "true"
fi

# Configure Undecorate
if is_extension_installed "undecoratex@lennart.github.io"; then
    log_info "Configuring Undecorate..."
    set_gsetting "org.gnome.shell.extensions.undecoratex" "trigger-mode" "2"
    set_gsetting "org.gnome.shell.extensions.undecoratex" "whitelist" "['Firefox', 'Brave', 'Code', 'Terminal', 'Ghostty']"
fi

log_info "GNOME extensions configuration completed"
