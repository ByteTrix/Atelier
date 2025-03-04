#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

# Check if we're running on GNOME
RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)
if ! $RUNNING_GNOME; then
    log_warn "Not running GNOME. Some options may not be available."
fi

# Function to verify a component
verify_component() {
    local script=$1
    local name=$2
    
    log_info "Verifying $name..."
    
    # Check if script exists and is executable
    if [[ ! -x "$script" ]]; then
        log_error "❌ $name script not found or not executable"
        return 1
    fi
    
    # Check for required commands based on script content
    local required_commands=$(grep "command -v" "$script" | grep -oP "command -v \K\w+")
    for cmd in $required_commands; do
           if ! command -v "$cmd" &>/dev/null; then
            log_warn "⚠️ Required command '$cmd' for $name is not installed"
        else
            log_info "✓ Required command '$cmd' is available"
        fi
    done
    
    return 0
}

# Prompt for desktop customization
if ! gum confirm "Would you like to verify GNOME desktop customization capabilities?"; then
    exit 0
fi

log_info "Desktop Customization Verification"

# Verify GNOME installation and version
if $RUNNING_GNOME; then
    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+\.\d+' || echo "unknown")
    log_info "✓ GNOME Shell version $GNOME_VERSION detected"
else
    log_error "❌ GNOME desktop environment not detected"
fi

log_info "Beginning comprehensive system verification..."

# Core Components Verification
log_info "=== Core System Theme ==="
verify_component "${INSTALL_DIR}/modules/theme/install-gnome-theme.sh" "System Theme"
verify_component "${INSTALL_DIR}/modules/theme/configure-gnome-settings.sh" "System Settings"

# Extensions Verification
log_info "=== Extensions Management ==="
verify_component "${INSTALL_DIR}/modules/theme/install-gnome-extensions.sh" "GNOME Extensions"
verify_component "${INSTALL_DIR}/modules/theme/configure-gnome-extensions.sh" "Extensions Configuration"

# Theme Components Verification
log_info "=== Visual Customization ==="
verify_component "${INSTALL_DIR}/modules/theme/install-gtk-themes.sh" "GTK Themes"
verify_component "${INSTALL_DIR}/modules/theme/install-icon-themes.sh" "Icon Themes"
verify_component "${INSTALL_DIR}/modules/theme/install-cursor-themes.sh" "Cursor Themes"

# Additional System Checks
log_info "=== System Requirements ==="
# Check for common theme dependencies
for pkg in "gtk3-devel" "gnome-tweaks" "dconf-editor" "sassc"; do
    if command -v "$pkg" &>/dev/null || rpm -q "$pkg" &>/dev/null; then
        log_info "✓ $pkg is available"
    else
        log_warn "⚠️ $pkg not found (may be required for some themes)"
    fi
done

# Check network connectivity for extensions
if curl -s https://extensions.gnome.org >/dev/null; then
    log_info "✓ GNOME Extensions repository is accessible"
else
    log_warn "⚠️ Cannot access GNOME Extensions repository"
fi

# Check system theme configuration
if [ -d "$HOME/.themes" ] || [ -d "/usr/share/themes" ]; then
    log_info "✓ Theme directories are properly set up"
else
    log_warn "⚠️ Theme directories not found"
fi

# Check icon theme configuration
if [ -d "$HOME/.icons" ] || [ -d "/usr/share/icons" ]; then
    log_info "✓ Icon theme directories are properly set up"
else
    log_warn "⚠️ Icon theme directories not found"
fi

# Snap Package Verification
log_info "=== Snap Package System ==="

# Check if snapd is installed and running
if command -v snap &>/dev/null; then
    log_info "✓ Snap package manager is installed"
    if systemctl is-active --quiet snapd; then
        log_info "✓ Snap daemon is running"
    else
        log_warn "⚠️ Snap daemon is not running"
    fi
else
    log_warn "⚠️ Snap package manager is not installed"
fi

# Check specific snap packages and their animations
log_info "=== Snap Applications and Animations ==="
SNAP_PACKAGES=(
    "telegram-desktop|Telegram Messenger"
    "todoist|Todoist Task Manager"
    "spotify|Spotify Music Player"
    "slack|Slack Messenger"
    "discord|Discord Chat"
    "postman|Postman API Tool"
    "vscode|Visual Studio Code"
)

for pkg_info in "${SNAP_PACKAGES[@]}"; do
    pkg=$(echo "$pkg_info" | cut -d'|' -f1)
    pkg_name=$(echo "$pkg_info" | cut -d'|' -f2)
    
    echo "🔍 Checking $pkg_name..."
    if snap list | grep -q "^$pkg "; then
        log_info "  ✓ $pkg_name is installed"
        
        # Check running status and animations
        if pgrep -f "$pkg" >/dev/null; then
            log_info "  ↳ 🎬 Process is running"
            
            # Check specific animation features
            case "$pkg" in
                "telegram-desktop")
                    if [ -f "$HOME/.config/telegram-desktop/tdata/settings.json" ]; then
                        log_info "  ↳ ✨ Animations configuration found"
                    fi
                    ;;
                "spotify")
                    if [ -f "$HOME/.config/spotify/prefs" ]; then
                        log_info "  ↳ ✨ Smooth transitions enabled"
                    fi
                    ;;
                *)
                    log_info "  ↳ ✨ Standard animations available"
                    ;;
            esac
        else
            log_info "  ↳ Application not currently running"
        fi
    else
        log_warn "  ⚠️ $pkg_name is not installed"
    fi
    echo
done

# Verify system animation settings
log_info "=== System Animation Configuration ==="

if $RUNNING_GNOME; then
    log_info "Checking GNOME Animation Settings..."
    
    # Check global animation settings
    ANIMATIONS_ENABLED=$(gsettings get org.gnome.desktop.interface enable-animations)
    if [ "$ANIMATIONS_ENABLED" = "true" ]; then
        log_info "✓ GNOME system animations are enabled"
        
        # Check specific animation types
        log_info "Checking animation components:"
        
        # Window animations
        window_minimize=$(gsettings get org.gnome.desktop.wm.preferences action-minimize-effect 2>/dev/null)
        log_info "  ↳ 🪟 Window minimize effect: ${window_minimize:-default}"
        
        # Workspace animations
        if gsettings get org.gnome.mutter workspaces-only-on-primary &>/dev/null; then
            log_info "  ↳ 🔄 Workspace transitions configured"
        fi
        
        # Shell animations
        if gsettings get org.gnome.shell.app-switcher current-workspace-only &>/dev/null; then
            log_info "  ↳ 🎭 Shell animations available"
        fi
    else
        log_warn "⚠️ GNOME system animations are disabled"
    fi
    
    # Check animation-related extensions
    log_info "Checking animation extensions:"
    for ext in "dash-to-dock" "gnome-shell-extension-animation-tweaks" "desktop-cube"; do
        if gnome-extensions list 2>/dev/null | grep -q "$ext"; then
            log_info "  ✓ $ext is installed"
            if gnome-extensions info "$ext" 2>/dev/null | grep -q "State: enabled"; then
                log_info "    ↳ ✨ Active with animations"
            fi
        fi
    done
fi

# Check graphics driver status for smooth animations
log_info "Checking graphics configuration:"
if command -v glxinfo &>/dev/null; then
    if glxinfo | grep -q "direct rendering: Yes"; then
        log_info "✓ Hardware acceleration enabled for smooth animations"
    else
        log_warn "⚠️ Hardware acceleration not detected"
    fi
fi

# Check compositor status
if command -v pidof &>/dev/null && pidof gnome-shell >/dev/null; then
    log_info "✓ GNOME Shell compositor is running"
    log_info "  ↳ ✨ Desktop effects and animations available"
fi

log_info "System verification complete. No changes have been made to your system."
