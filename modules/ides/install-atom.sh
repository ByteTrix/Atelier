#!/usr/bin/env bash
#
# Atom Installation
# ---------------
# Installs Atom text editor from the last available release
# Note: Atom has been sunset by GitHub but this script installs the last available version
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[atom] Installing Atom text editor..."

# Display sunset warning
log_warn "[atom] Note: Atom has been sunset by GitHub. Installing last available version."

# Check if Atom is already installed
if ! command -v atom &> /dev/null; then
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    
    # Download last available Atom .deb package
    log_info "[atom] Downloading Atom package..."
    wget -O "$TEMP_DIR/atom.deb" "https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb"
    
    # Install dependencies
    log_info "[atom] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y gconf2 gconf-service libgtk2.0-0 libudev1 libgcrypt20 \
                           notification-daemon libnotify4 libxtst6 libnss3 python \
                           gvfs-bin xdg-utils libx11-xcb1 libxss1 libasound2 libxkbfile1
    
    # Install Atom package
    log_info "[atom] Installing Atom package..."
    sudo dpkg -i "$TEMP_DIR/atom.deb"
    sudo apt-get install -f
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    # Create initial configuration directory
    mkdir -p "$HOME/.atom"
    
    # Create basic configuration
    log_info "[atom] Creating basic configuration..."
    cat > "$HOME/.atom/config.cson" << 'EOF'
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

    log_success "[atom] Atom text editor installed successfully!"
    
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
else
    log_warn "[atom] Atom is already installed."
fi

# Verify installation
if command -v atom &> /dev/null; then
    log_info "[atom] Atom installation verified."
    atom --version
else
    log_error "[atom] Atom installation could not be verified."
fi