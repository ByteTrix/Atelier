#!/usr/bin/env bash
#
# Icon Themes Installation
# ---------------------
# Installs popular icon themes for GNOME desktop
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[icon-themes] Installing icon themes..."

# Install dependencies
log_info "[icon-themes] Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    git \
    gtk-update-icon-cache \
    papirus-icon-theme \
    breeze-icon-theme

# Create icons directory
ICONS_DIR="$HOME/.icons"
mkdir -p "$ICONS_DIR"

# Function to clone and install an icon theme
install_icon_theme() {
    local repo_url="$1"
    local theme_name="$2"
    local install_cmd="$3"
    
    log_info "[icon-themes] Installing $theme_name..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Clone repository
    git clone --depth=1 "$repo_url" "$temp_dir"
    
    # Run installation command
    (cd "$temp_dir" && eval "$install_cmd")
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "[icon-themes] $theme_name installed successfully!"
}

# Install Numix Icon Theme
install_icon_theme \
    "https://github.com/numixproject/numix-icon-theme.git" \
    "Numix" \
    "cp -r Numix Numix-Light '$ICONS_DIR/'"

# Install Numix Circle Icon Theme
install_icon_theme \
    "https://github.com/numixproject/numix-icon-theme-circle.git" \
    "Numix Circle" \
    "cp -r Numix-Circle Numix-Circle-Light '$ICONS_DIR/'"

# Install Tela Icon Theme
install_icon_theme \
    "https://github.com/vinceliuice/Tela-icon-theme.git" \
    "Tela" \
    "./install.sh -a"

# Install Zafiro Icon Theme
install_icon_theme \
    "https://github.com/zayronxio/Zafiro-icons.git" \
    "Zafiro" \
    "cp -r . '$ICONS_DIR/Zafiro'"

# Update icon cache for all installed themes
log_info "[icon-themes] Updating icon caches..."
find "$ICONS_DIR" -name "icon-theme.cache" -delete
find "$ICONS_DIR" -type d -name "*[Ii]cons*" -exec gtk-update-icon-cache -f {} \;

# Configure default icon theme
log_info "[icon-themes] Configuring default icon theme..."
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
fi

# Create icon theme switcher script
log_info "[icon-themes] Creating icon theme switcher utility..."
cat > "$HOME/.local/bin/switch-icons" << 'EOF'
#!/bin/bash

# Get list of installed icon themes
ICONS_DIR="$HOME/.icons"
SYSTEM_ICONS_DIR="/usr/share/icons"

if [ ! -d "$ICONS_DIR" ] && [ ! -d "$SYSTEM_ICONS_DIR" ]; then
    echo "No icon themes directory found!"
    exit 1
fi

# Combine user and system icon themes
themes=()
if [ -d "$ICONS_DIR" ]; then
    themes+=($(ls "$ICONS_DIR"))
fi
if [ -d "$SYSTEM_ICONS_DIR" ]; then
    themes+=($(ls "$SYSTEM_ICONS_DIR"))
fi

# Remove duplicates
themes=($(printf "%s\n" "${themes[@]}" | sort -u))

if [ ${#themes[@]} -eq 0 ]; then
    echo "No icon themes found!"
    exit 1
fi

# Use dialog to create selection menu
if ! command -v dialog &> /dev/null; then
    sudo apt-get install -y dialog
fi

# Create temporary file for dialog output
temp_file=$(mktemp)

# Create dialog menu
dialog --clear --title "Icon Theme Switcher" \
       --menu "Choose an icon theme:" 15 40 4 \
       "${themes[@]/#/'' }" 2> "$temp_file"

# Get selected theme
selected_theme=$(cat "$temp_file")
rm "$temp_file"

if [ -n "$selected_theme" ]; then
    gsettings set org.gnome.desktop.interface icon-theme "$selected_theme"
    echo "Icon theme switched to: $selected_theme"
fi
EOF

chmod +x "$HOME/.local/bin/switch-icons"

log_success "[icon-themes] Icon themes installation complete!"

# Display help information
log_info "[icon-themes] Quick start guide:"
echo "
Installed Icon Themes:
- Numix
- Numix Circle (Default)
- Tela
- Zafiro
- Papirus
- Breeze

Usage:
- Switch icon themes using GNOME Tweaks
- Or use the icon theme switcher: switch-icons
- Icon themes are located in: $ICONS_DIR

Note: Some icon themes may require logging out and back in to take full effect.
"

# Verify installation
log_info "[icon-themes] Verifying installation..."
if [ -d "$ICONS_DIR" ]; then
    echo "Installed icon themes:"
    ls -1 "$ICONS_DIR"
fi