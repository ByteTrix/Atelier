#!/usr/bin/env bash
#
# GTK Themes Installation
# ---------------------
# Installs popular GTK themes for GNOME desktop
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check for required commands
required_commands=("git" "gsettings" "sudo" "apt-get")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "[gtk-themes] Required command not found: $cmd"
        return 1
    fi
done

log_info "[gtk-themes] Installing GTK themes..."

# Install dependencies
log_info "[gtk-themes] Installing dependencies..."
if ! sudo apt-get update; then
    log_error "[gtk-themes] Failed to update package list"
    return 1
fi

if ! sudo apt-get install -y \
    git \
    sassc \
    libglib2.0-dev \
    libxml2-utils \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf; then
    log_error "[gtk-themes] Failed to install dependencies"
    return 1
fi

# Create themes directory
THEMES_DIR="$HOME/.themes"
if ! mkdir -p "$THEMES_DIR"; then
    log_error "[gtk-themes] Failed to create themes directory"
    return 1
fi

# Function to clone and install a theme
install_theme() {
    local repo_url="$1"
    local theme_name="$2"
    local install_cmd="$3"
    
    log_info "[gtk-themes] Installing $theme_name..."
    
    # Create temporary directory
    local temp_dir
    if ! temp_dir=$(mktemp -d); then
        log_error "[gtk-themes] Failed to create temporary directory for $theme_name"
        return 1
    fi
    
    # Clone repository
    if ! git clone --depth=1 "$repo_url" "$temp_dir"; then
        log_error "[gtk-themes] Failed to clone $theme_name repository"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Run installation command
    if ! (cd "$temp_dir" && eval "$install_cmd"); then
        log_error "[gtk-themes] Failed to install $theme_name"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "[gtk-themes] $theme_name installed successfully!"
    return 0
}

# Install Nordic Theme
if ! install_theme \
    "https://github.com/EliverLara/Nordic.git" \
    "Nordic" \
    "cp -r . '$THEMES_DIR/Nordic'"; then
    log_warn "[gtk-themes] Failed to install Nordic theme"
fi

# Install Dracula Theme
if ! install_theme \
    "https://github.com/dracula/gtk.git" \
    "Dracula" \
    "cp -r . '$THEMES_DIR/Dracula'"; then
    log_warn "[gtk-themes] Failed to install Dracula theme"
fi

# Install Arc Theme
if ! install_theme \
    "https://github.com/jnsh/arc-theme.git" \
    "Arc" \
    "./autogen.sh --prefix=/usr && make && sudo make install"; then
    log_warn "[gtk-themes] Failed to install Arc theme"
fi

# Install Materia Theme
if ! install_theme \
    "https://github.com/nana-4/materia-theme.git" \
    "Materia" \
    "./install.sh"; then
    log_warn "[gtk-themes] Failed to install Materia theme"
fi

# Configure default theme
log_info "[gtk-themes] Configuring default theme..."
if command -v gsettings &> /dev/null; then
    if ! gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'; then
        log_warn "[gtk-themes] Failed to set GTK theme"
    fi
    if ! gsettings set org.gnome.desktop.wm.preferences theme 'Nordic'; then
        log_warn "[gtk-themes] Failed to set window manager theme"
    fi
fi

# Create theme switcher script
log_info "[gtk-themes] Creating theme switcher utility..."
if ! mkdir -p "$HOME/.local/bin"; then
    log_error "[gtk-themes] Failed to create bin directory"
    return 1
fi

if ! cat > "$HOME/.local/bin/switch-theme" << 'EOF'
#!/bin/bash

# Get list of installed themes
THEMES_DIR="$HOME/.themes"
if [ ! -d "$THEMES_DIR" ]; then
    echo "No themes directory found!"
    return 1
fi

# List available themes
themes=($(ls "$THEMES_DIR"))
if [ ${#themes[@]} -eq 0 ]; then
    echo "No themes found!"
    return 1
fi

# Use dialog to create selection menu
if ! command -v dialog &> /dev/null; then
    if ! sudo apt-get install -y dialog; then
        echo "Failed to install dialog"
        return 1
    fi
fi

# Create temporary file for dialog output
if ! temp_file=$(mktemp); then
    echo "Failed to create temporary file"
    return 1
fi

# Create dialog menu
dialog --clear --title "Theme Switcher" \
       --menu "Choose a theme:" 15 40 4 \
       "${themes[@]/#/'' }" 2> "$temp_file"

# Get selected theme
selected_theme=$(cat "$temp_file")
rm "$temp_file"

if [ -n "$selected_theme" ]; then
    if ! gsettings set org.gnome.desktop.interface gtk-theme "$selected_theme"; then
        echo "Failed to set GTK theme"
        return 1
    fi
    if ! gsettings set org.gnome.desktop.wm.preferences theme "$selected_theme"; then
        echo "Failed to set window manager theme"
        return 1
    fi
    echo "Theme switched to: $selected_theme"
fi
EOF
then
    log_error "[gtk-themes] Failed to create theme switcher script"
    return 1
fi

if ! chmod +x "$HOME/.local/bin/switch-theme"; then
    log_error "[gtk-themes] Failed to make theme switcher executable"
    return 1
fi

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
else
    log_error "[gtk-themes] Themes directory not found"
    return 1
fi