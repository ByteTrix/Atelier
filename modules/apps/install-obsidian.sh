#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Obsidian is already installed
if snap list obsidian &>/dev/null; then
    log_warn "[apps] Obsidian is already installed"
    snap list obsidian
    return 0
fi

log_info "[apps] Installing Obsidian..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[apps] Snap is not installed. Please install snapd first."
    return 1
fi

# Install Obsidian
if ! snap install obsidian --classic; then
    log_error "[apps] Failed to install Obsidian"
    return 1
fi

# Verify installation
if snap list obsidian &>/dev/null; then
    log_success "[apps] Obsidian installed successfully"
    snap list obsidian
    return 0
else
    log_error "[apps] Obsidian installation could not be verified"
    return 1
fi
