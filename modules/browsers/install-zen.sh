#!/usr/bin/env bash
#
# Zen Browser Installer
# -------------------
# Installs the Zen minimalist web browser
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

log_info "[browsers/zen] Checking if Zen Browser is already installed..."

if command -v zen-browser &>/dev/null; then
    log_info "[browsers/zen] Zen Browser is already installed"
    
    # Display version info if available
    if zen-browser --version &>/dev/null; then
        INSTALLED_VERSION=$(zen-browser --version | head -n1)
        log_info "[browsers/zen] Installed version: $INSTALLED_VERSION"
    fi
    exit 0
fi

log_info "[browsers/zen] Installing Zen Browser..."

# Add the Zen Browser repository key
log_info "[browsers/zen] Adding repository key..."
if ! curl -fsSL https://download.opensuse.org/repositories/home:/Zen/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/zen-browser.gpg > /dev/null; then
    log_error "[browsers/zen] Failed to add repository key"
    exit 1
fi

# Add the repository
log_info "[browsers/zen] Adding repository source..."
echo "deb https://download.opensuse.org/repositories/home:/Zen/xUbuntu_22.04/ /" | sudo tee /etc/apt/sources.list.d/zen-browser.list

# Update package lists
log_info "[browsers/zen] Updating package lists..."
if ! sudo apt update; then
    log_error "[browsers/zen] Failed to update package lists"
    exit 1
fi

# Install Zen Browser
log_info "[browsers/zen] Installing Zen Browser package..."
if ! sudo apt install -y zen-browser; then
    log_error "[browsers/zen] Failed to install Zen Browser"
    exit 1
fi

log_info "[browsers/zen] Zen Browser installed successfully"
log_info "[browsers/zen] Run 'zen-browser' to launch the browser"
