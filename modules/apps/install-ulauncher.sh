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
    # Install Ulauncher
    log_info "[ulauncher] Installing Ulauncher..."
    sudo add-apt-repository -y ppa:agornostal/ulauncher
    sudo apt-get update
    sudo apt-get install -y ulauncher

    # Enable service and autostart
    systemctl --user enable --now ulauncher
    mkdir -p "$HOME/.config/autostart"
    cp /usr/share/applications/ulauncher.desktop "$HOME/.config/autostart/"

    log_success "[ulauncher] Ulauncher installed successfully!"
else
    log_warn "[ulauncher] Ulauncher is already installed"
fi

# Verify installation
if command -v ulauncher &> /dev/null; then
    log_info "[ulauncher] Version information:"
    ulauncher --version
else
    log_error "[ulauncher] Installation failed"
    exit 1
fi
