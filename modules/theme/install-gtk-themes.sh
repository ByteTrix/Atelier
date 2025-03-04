#!/usr/bin/env bash
#
# GTK Themes Installation
# ---------------------
# Installs popular GTK themes for GNOME desktop
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[gtk-themes] Installing GTK themes..."

# Install dependencies
log_info "[gtk-themes] Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    git \
    sassc \
    libglib2.0-dev \
    libxml2-utils \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf

# Create themes directory
THEMES_DIR="$HOME/.themes"
mkdir -p "$THEMES_DIR"

# Function to clone and install a theme
install_theme() {
    local repo_url="$1"
    local theme_name="$2"
    local install_cmd="$3"
    
    log_info "[gtk-themes] Installing $theme_name..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Clone repository
    git clone --depth=1 "$repo_url" "$temp_dir"
    
    # Run installation command
    (cd "$temp_dir" && eval "$install_cmd")
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "[gtk-themes] $theme_name installed successfully!"
}

# Install Nordic Theme
install_theme \
    "https://github.com/EliverLara/Nordic.git" \
    "Nordic" \
    "cp -r . '$THEMES_DIR/Nordic'"

# Install Dracula Theme
install_theme \
    "https://github.com/dracula/gtk.git" \
    "Dracula" \
    "cp -r . '$THEMES_DIR/Dracula'"

# Install Arc Theme
install_theme \
    "https://github.com/jnsh/arc-theme.git" \
    "Arc" \
    "./autogen.sh --prefix=/usr && make && sudo make install"

# Install Materia Theme
install_theme \
    "https://github.com/nana-4/materia-theme.git" \
    "Materia" \
    "./install.sh"

# Configure default theme
log_info "[gtk-themes] Configuring default theme..."
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'
    gsettings set org.gnome.desktop.wm.preferences theme 'Nordic'
fi

# Create theme switcher script
log_info "[gtk-themes] Creating theme switcher utility..."
cat > "$HOME/.local/bin/switch-theme" << 'EOF'
#!/bin/bash

# Get list of installed themes
THEMES_DIR="$HOME/.themes"
if [ ! -d "$THEMES_DIR" ]; then
    echo "No themes directory found!"
    exit 1
fi

# List available themes
themes=($(ls "$THEMES_DIR"))
if [ ${#themes[@]} -eq 0 ]; then
    echo "No themes found!"
    exit 1
fi

# Use dialog to create selection menu
if ! command -v dialog &> /dev/null; then
    sudo apt-get install -y dialog
fi

# Create temporary file for dialog output
temp_file=$(mktemp)

# Create dialog menu
dialog --clear --title "Theme Switcher" \
       --menu "Choose a theme:" 15 40 4 \
       "${themes[@]/#/'' }" 2> "$temp_file"

# Get selected theme
selected_theme=$(cat "$temp_file")
rm "$temp_file"

if [ -n "$selected_theme" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$selected_theme"
    gsettings set org.gnome.desktop.wm.preferences theme "$selected_theme"
    echo "Theme switched to: $selected_theme"
fi
EOF

chmod +x "$HOME/.local/bin/switch-theme"

log_success "[gtk-themes] GTK themes installation complete!"

# Display help information
log_info "[gtk-themes] Quick start guide:"
echo "
Installed Themes:
- Nordic (Default)
- Dracula
- Arc
- Materia

Usage:
- Switch themes using GNOME Tweaks
- Or use the theme switcher: switch-theme
- Theme files are located in: $THEMES_DIR

Note: Some themes may require logging out and back in to take full effect.
"

# Verify installation
log_info "[gtk-themes] Verifying installation..."
if [ -d "$THEMES_DIR" ]; then
    echo "Installed themes:"
    ls -1 "$THEMES_DIR"
fi