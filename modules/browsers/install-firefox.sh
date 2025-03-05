#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Firefox is already installed
if command -v firefox &>/dev/null; then
    log_warn "[browsers] Firefox is already installed"
    firefox --version
    return 0
fi

log_info "[browsers] Installing Firefox..."

# Update package lists
if ! sudo_exec apt-get update; then
    log_error "[browsers] Failed to update package lists"
    return 1
fi

# Install Firefox
if ! sudo_exec apt-get install -y firefox; then
    log_error "[browsers] Failed to install Firefox"
    return 1
fi

# Verify installation
if command -v firefox &>/dev/null; then
    log_success "[browsers] Firefox installed successfully"
    firefox --version
    return 0
else
    log_error "[browsers] Firefox installation could not be verified"
    return 1
fi
