#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if VLC is already installed
if command -v vlc &>/dev/null; then
    log_warn "[apps] VLC Media Player is already installed"
    vlc --version 2>/dev/null || true
    return 0
fi

log_info "[apps] Installing VLC Media Player..."

# Update package lists
if ! sudo_exec apt-get update; then
    log_error "[apps] Failed to update package lists"
    return 1
fi

# Install VLC
if ! sudo_exec apt-get install -y vlc; then
    log_error "[apps] Failed to install VLC"
    return 1
fi

# Verify installation
if command -v vlc &>/dev/null; then
    log_success "[apps] VLC Media Player installed successfully"
    vlc --version 2>/dev/null || true
    return 0
else
    log_error "[apps] VLC installation could not be verified"
    return 1
fi
