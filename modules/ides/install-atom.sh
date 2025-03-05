#!/usr/bin/env bash
#
# Atom Installation
# ---------------
# Installs Atom text editor from the last available release
# Note: Atom has been sunset by GitHub but this script installs the last available version
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Atom is already installed
if command -v atom &>/dev/null; then
    log_warn "[atom] Atom is already installed"
    atom --version
    return 0
fi

log_info "[atom] Installing Atom text editor..."

# Display sunset warning
log_warn "[atom] Note: Atom has been sunset by GitHub. Installing last available version."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || {
    log_error "[atom] Failed to create temporary directory"
    return 1
}

# Download last available Atom .deb package
log_info "[atom] Downloading Atom package..."
if ! wget -O atom.deb "https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb"; then
    log_error "[atom] Failed to download Atom package"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Install dependencies
log_info "[atom] Installing dependencies..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y gconf2 gconf-service libgtk2.0-0 libudev1 libgcrypt20 \
    notification-daemon libnotify4 libxtst6 libnss3 python \
    gvfs-bin xdg-utils libx11-xcb1 libxss1 libasound2 libxkbfile1; then
    log_error "[atom] Failed to install dependencies"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Install Atom package
log_info "[atom] Installing Atom package..."
if ! sudo_exec dpkg -i "$TEMP_DIR/atom.deb"; then
    if ! sudo_exec apt-get install -f -y; then
        log_error "[atom] Failed to install Atom dependencies"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    # Try installing again after fixing dependencies
    if ! sudo_exec dpkg -i "$TEMP_DIR/atom.deb"; then
        log_error "[atom] Failed to install Atom package"
        rm -rf "$TEMP_DIR"
        return 1
    fi
fi

# Clean up
cd - &>/dev/null || true
rm -rf "$TEMP_DIR"

# Create initial configuration directory
if ! mkdir -p "$HOME/.atom"; then
    log_warn "[atom] Failed to create configuration directory"
fi

# Create basic configuration
log_info "[atom] Creating basic configuration..."
CONFIG_FILE="$HOME/.atom/config.cson"
cat > "$CONFIG_FILE" << 'EOF' || {
"*":
  core:
    telemetryConsent: "no"
    themes: [
      "one-dark-ui"
      "one-dark-syntax"
    ]
  editor:
    fontSize: 14
    showIndentGuide: true
    showInvisibles: true
    softWrap: true
  "exception-reporting":
    userId: "00000000-0000-0000-0000-000000000000"
  welcome:
    showOnStartup: false
EOF
    log_warn "[atom] Failed to create configuration file"
}

# Verify installation
if command -v atom &>/dev/null; then
    log_success "[atom] Atom text editor installed successfully"
    atom --version
    
    # Display help information
    log_info "[atom] Quick start guide:"
    echo "
    - Launch Atom: atom
    - Open Command Palette: Ctrl+Shift+P
    - Install Package: Settings (Ctrl+,) -> Install
    - Popular packages to consider:
      * file-icons: Assign file extension icons
      * minimap: Source code preview
      * atom-beautify: Code formatting
      * highlight-selected: Highlight occurrences of selected text
    "
    
    # Display sunset notice again
    log_warn "[atom] Remember: Atom is no longer actively maintained. Consider alternatives like VS Code or Sublime Text for long-term use."
    return 0
else
    log_error "[atom] Atom installation could not be verified"
    return 1
fi