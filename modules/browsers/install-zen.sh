#!/usr/bin/env bash
#
# Zen Browser Installer
# -------------------
# Installs the Zen minimalist web browser
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Zen Browser is already installed
if command -v zen-browser &>/dev/null; then
    log_warn "[browsers/zen] Zen Browser is already installed"
    if zen-browser --version &>/dev/null; then
        INSTALLED_VERSION=$(zen-browser --version | head -n1)
        log_info "[browsers/zen] Installed version: $INSTALLED_VERSION"
    fi
    return 0
fi

log_info "[browsers/zen] Installing Zen Browser..."

# Create keyrings directory
sudo_exec mkdir -p /usr/share/keyrings

# Add the Zen Browser repository key
log_info "[browsers/zen] Adding repository key..."
if ! curl -fsSL https://download.opensuse.org/repositories/home:/Zen/xUbuntu_22.04/Release.key | sudo_exec gpg --dearmor -o /usr/share/keyrings/zen-browser-archive-keyring.gpg; then
    log_error "[browsers/zen] Failed to add repository key"
    return 1
fi

# Add the repository
log_info "[browsers/zen] Adding repository source..."
if ! echo "deb [signed-by=/usr/share/keyrings/zen-browser-archive-keyring.gpg] https://download.opensuse.org/repositories/home:/Zen/xUbuntu_22.04/ /" | sudo_exec tee /etc/apt/sources.list.d/zen-browser.list > /dev/null; then
    log_error "[browsers/zen] Failed to add repository"
    return 1
fi

# Update package lists
log_info "[browsers/zen] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[browsers/zen] Failed to update package lists"
    return 1
fi

# Install Zen Browser
log_info "[browsers/zen] Installing Zen Browser package..."
if ! sudo_exec apt-get install -y zen-browser; then
    log_error "[browsers/zen] Failed to install Zen Browser"
    return 1
fi

# Verify installation
if command -v zen-browser &>/dev/null; then
    log_success "[browsers/zen] Zen Browser installed successfully"
    if zen-browser --version &>/dev/null; then
        INSTALLED_VERSION=$(zen-browser --version | head -n1)
        log_info "[browsers/zen] Installed version: $INSTALLED_VERSION"
    fi
    return 0
else
    log_error "[browsers/zen] Zen Browser installation could not be verified"
    return 1
fi
