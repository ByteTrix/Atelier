#!/usr/bin/env bash
#
# Google Chrome Installation
# -----------------------
# Installs Google Chrome web browser
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[chrome] Installing Google Chrome..."

# Check if Chrome is already installed
if ! command -v google-chrome &> /dev/null; then
    # Install dependencies and add repository
    log_info "[chrome] Setting up Google Chrome repository..."
    sudo apt-get update
    sudo apt-get install -y curl apt-transport-https
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    # Install Chrome
    log_info "[chrome] Installing Google Chrome..."
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable

    log_success "[chrome] Google Chrome installed successfully!"
else
    log_warn "[chrome] Google Chrome is already installed"
fi

# Verify installation
if command -v google-chrome &> /dev/null; then
    log_info "[chrome] Version information:"
    google-chrome --version
else
    log_error "[chrome] Installation failed"
    exit 1
fi
