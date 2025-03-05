#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Spotify is already installed
if snap list spotify &>/dev/null; then
    log_warn "[apps] Spotify is already installed"
    snap list spotify
    return 0
fi

log_info "[apps] Installing Spotify..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[apps] Snap is not installed. Please install snapd first."
    return 1
fi

# Install Spotify
if ! snap install spotify; then
    log_error "[apps] Failed to install Spotify"
    return 1
fi

# Verify installation
if snap list spotify &>/dev/null; then
    log_success "[apps] Spotify installed successfully"
    snap list spotify
    return 0
else
    log_error "[apps] Spotify installation could not be verified"
    return 1
fi
