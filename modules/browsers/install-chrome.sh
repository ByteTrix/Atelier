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
    # Install dependencies
    log_info "[chrome] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y curl apt-transport-https

    # Download and add the Google Chrome repository key
    log_info "[chrome] Adding Google Chrome repository..."
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-archive-keyring.gpg

    # Add the Google Chrome repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    # Update package lists and install Chrome
    log_info "[chrome] Installing Google Chrome..."
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable

    # Create desktop shortcut if not exists
    if [ ! -f "$HOME/.local/share/applications/google-chrome.desktop" ]; then
        log_info "[chrome] Creating desktop shortcut..."
        mkdir -p "$HOME/.local/share/applications"
        cp /usr/share/applications/google-chrome.desktop "$HOME/.local/share/applications/"
    fi

    # Optional: Set as default browser
    if gum confirm "Would you like to set Google Chrome as your default browser?"; then
        xdg-settings set default-web-browser google-chrome.desktop
        log_info "[chrome] Google Chrome set as default browser."
    fi

    log_success "[chrome] Google Chrome installed successfully!"

    # Display help information
    log_info "[chrome] Quick start guide:"
    echo "
    - Launch Chrome: google-chrome
    - Open in incognito: google-chrome --incognito
    - Create desktop shortcut: Menu -> More tools -> Create shortcut
    - Import bookmarks: Menu -> Bookmarks -> Import bookmarks and settings
    - Sync account: Sign in with your Google account
    "
else
    log_warn "[chrome] Google Chrome is already installed."
fi

# Verify installation
if command -v google-chrome &> /dev/null; then
    log_info "[chrome] Google Chrome installation verified."
    google-chrome --version
else
    log_error "[chrome] Google Chrome installation could not be verified."
    exit 1
fi
