#!/usr/bin/env bash
set -euo pipefail

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo"
    exit 1
fi

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

log_info "Starting system update..."

# Update package list
log_info "Updating package lists..."
if ! sudo apt update; then
    log_error "Failed to update package lists"
    exit 1
fi

# Upgrade packages
log_info "Upgrading system packages..."
if ! sudo apt upgrade -y; then
    log_error "Failed to upgrade packages"
    exit 1
fi

# Clean up
log_info "Cleaning up..."
if ! sudo apt autoremove -y && sudo apt clean; then
    log_warn "Cleanup encountered some issues but continuing..."
fi

log_success "System update completed successfully."
