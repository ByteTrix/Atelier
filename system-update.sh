#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

# Initialize sudo session at the start
init_sudo_session

log_info "Starting system update..."

# Wait for any existing package operations to complete
if ! wait_for_apt_locks; then
    log_error "Package manager is busy and timed out waiting"
    exit 1
fi

# Update package list
log_info "Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "Failed to update package lists"
    exit 1
fi

# Upgrade packages
log_info "Upgrading system packages..."
if ! sudo_exec apt-get upgrade -y; then
    log_error "Failed to upgrade packages"
    exit 1
fi

# Clean up
log_info "Cleaning up..."
if ! sudo_exec apt-get autoremove -y && sudo_exec apt-get clean; then
    log_warn "Cleanup encountered some issues but continuing..."
fi

log_info "System update completed successfully."
