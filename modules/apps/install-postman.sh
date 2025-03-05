#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if already installed
if command -v postman &>/dev/null; then
    log_warn "[apps] Postman is already installed"
    postman --version
    exit 0
fi

log_info "[apps] Installing Postman..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[apps] Snap is not installed. Please install snapd first."
    return 1
fi

# Install Postman
if ! snap install postman; then
    log_error "[apps] Failed to install Postman"
    return 1
fi

# Verify installation
if command -v postman &>/dev/null; then
    log_success "[apps] Postman installed successfully"
    postman --version
    return 0
else
    log_error "[apps] Postman installation could not be verified"
    return 1
fi