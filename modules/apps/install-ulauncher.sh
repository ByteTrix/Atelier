#!/usr/bin/env bash
#
# Ulauncher Installation
# -------------------
# Installs Ulauncher application launcher
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ulauncher] Installing Ulauncher..."

# Check if Ulauncher is already installed
if ! command -v ulauncher &> /dev/null; then
    # Add Ulauncher PPA
    log_info "[ulauncher] Adding Ulauncher repository..."
    sudo add-apt-repository -y ppa:agornostal/ulauncher

    # Install Ulauncher
    log_info "[ulauncher] Installing Ulauncher..."
    sudo apt-get update
    sudo apt-get install -y ulauncher

    # Enable Ulauncher service
    log_info "[ulauncher] Enabling Ulauncher service..."
    systemctl --user enable --now ulauncher

    # Configure autostart
    mkdir -p "$HOME/.config/autostart"
    cp /usr/share/applications/ulauncher.desktop "$HOME/.config/autostart/"

    log_success "[ulauncher] Ulauncher installed successfully!"

    # Display help information
    log_info "[ulauncher] Quick start guide:"
    echo "
    - Launch Ulauncher: Super + Space (default shortcut)
    - Configure preferences: Open Ulauncher settings
    - Add extensions: Visit https://ext.ulauncher.io/
    - Change theme: Settings > Appearance
    "
else
    log_warn "[ulauncher] Ulauncher is already installed."
fi

# Verify installation
if command -v ulauncher &> /dev/null; then
    log_info "[ulauncher] Ulauncher installation verified."
    ulauncher --version
else
    log_error "[ulauncher] Ulauncher installation could not be verified."
    exit 1
fi
