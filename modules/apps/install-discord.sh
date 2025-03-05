#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Discord is already installed
if snap list discord &>/dev/null; then
    log_warn "[apps] Discord is already installed"
    snap list discord
    return 0
fi

log_info "[apps] Installing Discord..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[apps] Snap is not installed. Please install snapd first."
    return 1
fi

# Install Discord
if ! snap install discord; then
    log_error "[apps] Failed to install Discord"
    return 1
fi

# Verify installation
if snap list discord &>/dev/null; then
    log_success "[apps] Discord installed successfully"
    snap list discord
    return 0
else
    log_error "[apps] Discord installation could not be verified"
    return 1
fi