#!/usr/bin/env bash
#
# System Cleanup Script
# -------------------
# Performs system cleanup after installation
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/lib/utils.sh"

# Determine sudo command based on environment
if [[ "${SETUPR_SUDO:-0}" == "1" ]]; then
    SUDO_CMD="sudo_exec"
else
    SUDO_CMD="sudo"
fi

log_info "Running system cleanup..."

# Clean package cache
log_info "Cleaning package cache..."
$SUDO_CMD apt clean || log_warn "Failed to clean apt cache"
$SUDO_CMD apt autoremove -y || log_warn "Failed to autoremove packages"

# Remove temporary files with error handling
log_info "Cleaning temporary files..."
if [ -d "/tmp" ]; then
    $SUDO_CMD rm -rf /tmp/* || log_warn "Failed to clean /tmp directory"
fi

# Clean user cache with error handling
log_info "Cleaning user cache..."
if [ -d "$HOME/.cache" ]; then
    rm -rf "$HOME/.cache/"* || log_warn "Failed to clean user cache"
fi

log_info "System cleanup complete."
