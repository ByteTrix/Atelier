#!/usr/bin/env bash
#
# Ghostty Terminal Installer
# ------------------------
# Installs the Ghostty GPU-accelerated terminal emulator
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

log_info "[cli/ghostty] Checking if Ghostty is already installed..."

if command -v ghostty &>/dev/null; then
    log_info "[cli/ghostty] Ghostty Terminal is already installed"
    
    # Check for updates if already installed
    INSTALLED_VERSION=$(ghostty --version | cut -d' ' -f2)
    log_info "[cli/ghostty] Installed version: $INSTALLED_VERSION"
    exit 0
fi

log_info "[cli/ghostty] Installing Ghostty Terminal..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
log_info "[cli/ghostty] Created temporary directory: $TEMP_DIR"
trap 'log_info "[cli/ghostty] Cleaning up temporary files..."; rm -rf $TEMP_DIR' EXIT

# Download and install Ghostty
cd "$TEMP_DIR"
GHOSTTY_VERSION="0.6.0"
log_info "[cli/ghostty] Downloading Ghostty v${GHOSTTY_VERSION}..."

if ! wget -q --show-progress "https://github.com/mitchellh/ghostty/releases/download/v${GHOSTTY_VERSION}/ghostty-linux-x86_64.tar.gz"; then
    log_error "[cli/ghostty] Failed to download Ghostty"
    exit 1
fi

log_info "[cli/ghostty] Extracting Ghostty..."
if ! tar xzf "ghostty-linux-x86_64.tar.gz"; then
    log_error "[cli/ghostty] Failed to extract Ghostty archive"
    exit 1
fi

# Install binary and desktop files
log_info "[cli/ghostty] Installing Ghostty to system..."
if ! sudo install -m755 ghostty /usr/local/bin/; then
    log_error "[cli/ghostty] Failed to install Ghostty binary"
    exit 1
fi

if ! sudo install -m644 ghostty.desktop /usr/share/applications/; then
    log_warn "[cli/ghostty] Failed to install desktop file, continuing anyway"
fi

# Create config directory if it doesn't exist
mkdir -p ~/.config/ghostty

# Create initial config file if it doesn't exist
if [ ! -f ~/.config/ghostty/config ]; then
    log_info "[cli/ghostty] Creating default configuration..."
    cat > ~/.config/ghostty/config << 'EOF'
# Ghostty Terminal Configuration
# -----------------------------
# See: https://github.com/mitchellh/ghostty

# Font settings
font-family = "JetBrains Mono"
font-size = 12

# Appearance
theme = "Dracula"
background-opacity = 0.98
window-padding-x = 10
window-padding-y = 10

# Cursor settings
cursor-style = block
cursor-blink = true

# Scrollback
scrollback-lines = 10000
EOF
    log_info "[cli/ghostty] Created default Ghostty config file"
fi

log_info "[cli/ghostty] Ghostty Terminal v${GHOSTTY_VERSION} installed successfully"
log_info "[cli/ghostty] Run 'ghostty' to launch the terminal"
