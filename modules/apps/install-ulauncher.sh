#!/usr/bin/env bash
#
# Ulauncher Installation
# -------------------
# Installs Ulauncher application launcher
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ulauncher] Installing Ulauncher..."

# Check if Ulauncher is already installed
if ! command -v ulauncher &> /dev/null; then
    # Install Ulauncher
    log_info "[ulauncher] Adding Ulauncher repository..."
    if ! sudo add-apt-repository -y ppa:agornostal/ulauncher; then
        log_error "[ulauncher] Failed to add repository"
        return 1
    fi

    log_info "[ulauncher] Updating package lists..."
    if ! sudo apt-get update; then
        log_error "[ulauncher] Failed to update package lists"
        return 1
    fi

    log_info "[ulauncher] Installing Ulauncher package..."
    if ! sudo apt-get install -y ulauncher; then
        log_error "[ulauncher] Failed to install Ulauncher"
        return 1
    fi

    # Enable service and autostart
    log_info "[ulauncher] Setting up autostart..."
    if ! systemctl --user enable --now ulauncher; then
        log_warn "[ulauncher] Failed to enable Ulauncher service, continuing anyway..."
    fi

    if ! mkdir -p "$HOME/.config/autostart"; then
        log_warn "[ulauncher] Failed to create autostart directory, continuing anyway..."
    fi

    if [ -f /usr/share/applications/ulauncher.desktop ]; then
        if ! cp /usr/share/applications/ulauncher.desktop "$HOME/.config/autostart/"; then
            log_warn "[ulauncher] Failed to copy autostart file, continuing anyway..."
        fi
    else
        log_warn "[ulauncher] Desktop file not found, autostart may not work"
    fi

    log_success "[ulauncher] Ulauncher installed successfully!"
else
    log_warn "[ulauncher] Ulauncher is already installed"
fi

# Verify installation
if command -v ulauncher &> /dev/null; then
    log_info "[ulauncher] Version information:"
    if ulauncher --version; then
        log_success "[ulauncher] Installation verified"
        return 0
    else
        log_error "[ulauncher] Version check failed"
        return 1
    fi
else
    log_error "[ulauncher] Installation failed"
    return 1
fi
