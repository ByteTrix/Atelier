#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Syncthing is already installed
if snap list syncthing &>/dev/null; then
    log_warn "[apps] Syncthing is already installed"
    snap list syncthing
    return 0
fi

log_info "[apps] Installing Syncthing..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[apps] Snap is not installed. Please install snapd first."
    return 1
fi

# Install Syncthing
if ! snap install syncthing; then
    log_error "[apps] Failed to install Syncthing"
    return 1
fi

# Verify installation
if snap list syncthing &>/dev/null; then
    log_success "[apps] Syncthing installed successfully"
    snap list syncthing
    return 0
else
    log_error "[apps] Syncthing installation could not be verified"
    return 1
fi
