#!/usr/bin/env bash
#
# Cursor Themes Installation
# -----------------------
# Installs popular cursor themes for GNOME desktop
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cursor-themes] Installing cursor themes..."

# Install dependencies
log_info "[cursor-themes] Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    git \
    x11-apps \
    breeze-cursor-theme \
    dmz-cursor-theme

# Create icons directory (cursor themes are stored in icons directory)
ICONS_DIR="$HOME/.icons"
mkdir -p "$ICONS_DIR"

# Function to install a cursor theme from tar.gz
install_cursor_theme_archive() {
    local url="$1"
    local theme_name="$2"
    
    log_info "[cursor-themes] Installing $theme_name..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Download and extract theme
    wget -qO "$temp_dir/theme.tar.gz" "$url"
    tar xf "$temp_dir/theme.tar.gz" -C "$ICONS_DIR"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "[cursor-themes] $theme_name installed successfully!"
}

# Function to clone and install a cursor theme from git
install_cursor_theme_git() {
    local repo_url="$1"
    local theme_name="$2"
    local install_cmd="$3"
    
    log_info "[cursor-themes] Installing $theme_name..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Clone repository
    git clone --depth=1 "$repo_url" "$temp_dir"
    
    # Run installation command
    (cd "$temp_dir" && eval "$install_cmd")
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "[cursor-themes] $theme_name installed successfully!"
}

# Install Bibata Cursor Theme
install_cursor_theme_git \
    "https://github.com/ful1e5/Bibata_Cursor.git" \
    "Bibata" \
    "./build.sh --install"

# Install Capitaine Cursors
install_cursor_theme_git \
    "https://github.com/keeferrourke/capitaine-cursors.git" \
    "Capitaine Cursors" \
    "cp -r dist/* '$ICONS_DIR/'"

# Install Vimix Cursors
install_cursor_theme_git \
    "https://github.com/vinceliuice/Vimix-cursors.git" \
    "Vimix" \
    "./install.sh"

# Install Nordzy Cursors
install_cursor_theme_git \
    "https://github.com/alvatip/Nordzy-cursors.git" \
    "Nordzy" \
    "./install.sh"

# Update icon caches
log_info "[cursor-themes] Updating icon caches..."
find "$ICONS_DIR" -name "icon-theme.cache" -delete
find "$ICONS_DIR" -type d -name "*cursors*" -exec gtk-update-icon-cache -f {} \; 2>/dev/null || true

# Configure default cursor theme
log_info "[cursor-themes] Configuring default cursor theme..."
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Original'
fi

# Create cursor theme switcher script
log_info "[cursor-themes] Creating cursor theme switcher utility..."
cat > "$HOME/.local/bin/switch-cursor" << 'EOF'
#!/bin/bash

# Get list of installed cursor themes
ICONS_DIR="$HOME/.icons"
SYSTEM_ICONS_DIR="/usr/share/icons"

if [ ! -d "$ICONS_DIR" ] && [ ! -d "$SYSTEM_ICONS_DIR" ]; then
    echo "No cursor themes directory found!"
    exit 1
fi

# Find directories containing 'cursors' subdirectory
themes=()
if [ -d "$ICONS_DIR" ]; then
    themes+=($(find "$ICONS_DIR" -type d -name "cursors" -exec dirname {} \; | xargs -n1 basename))
fi
if [ -d "$SYSTEM_ICONS_DIR" ]; then
    themes+=($(find "$SYSTEM_ICONS_DIR" -type d -name "cursors" -exec dirname {} \; | xargs -n1 basename))
fi

# Remove duplicates
themes=($(printf "%s\n" "${themes[@]}" | sort -u))

if [ ${#themes[@]} -eq 0 ]; then
    echo "No cursor themes found!"
    exit 1
fi

# Use dialog to create selection menu
if ! command -v dialog &> /dev/null; then
    sudo apt-get install -y dialog
fi

# Create temporary file for dialog output
temp_file=$(mktemp)

# Create dialog menu
dialog --clear --title "Cursor Theme Switcher" \
       --menu "Choose a cursor theme:" 15 40 4 \
       "${themes[@]/#/'' }" 2> "$temp_file"

# Get selected theme
selected_theme=$(cat "$temp_file")
rm "$temp_file"

if [ -n "$selected_theme" ]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$selected_theme"
    # Also update Xresources for compatibility
    echo "Xcursor.theme: $selected_theme" | tee -a "$HOME/.Xresources"
    xrdb -merge "$HOME/.Xresources"
    echo "Cursor theme switched to: $selected_theme"
    echo "Log out and back in for the change to take full effect."
fi
EOF

chmod +x "$HOME/.local/bin/switch-cursor"

log_success "[cursor-themes] Cursor themes installation complete!"

# Display help information
log_info "[cursor-themes] Quick start guide:"
echo "
Installed Cursor Themes:
- Bibata (Default)
- Capitaine Cursors
- Vimix
- Nordzy
- Breeze
- DMZ

Usage:
- Switch cursor themes using GNOME Tweaks
- Or use the cursor theme switcher: switch-cursor
- Cursor themes are located in: $ICONS_DIR

Note: 
- Log out and back in for cursor theme changes to take full effect
- Some applications may need to be restarted
"

# Verify installation
log_info "[cursor-themes] Verifying installation..."
if [ -d "$ICONS_DIR" ]; then
    echo "Installed cursor themes:"
    find "$ICONS_DIR" -type d -name "cursors" -exec dirname {} \; | xargs -n1 basename
fi