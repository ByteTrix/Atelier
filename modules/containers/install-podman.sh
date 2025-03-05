#!/usr/bin/env bash
#
# Podman Installation
# -----------------
# Installs Podman container engine
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Storage configuration
STORAGE_CONF='[storage]
driver = "overlay"
runroot = "/run/containers/storage"
graphroot = "/var/lib/containers/storage"
[storage.options]
additionalimagestores = []'

# Check if Podman is already installed
if command -v podman &>/dev/null; then
    log_warn "[podman] Podman is already installed"
    podman version
    return 0
fi

log_info "[podman] Installing Podman..."

# Install required packages
log_info "[podman] Installing dependencies..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y curl gpg; then
    log_error "[podman] Failed to install dependencies"
    return 1
fi

# Create keyrings directory
sudo_exec mkdir -p /etc/apt/keyrings

# Add the repository key
log_info "[podman] Adding Podman repository key..."
if ! source /etc/os-release; then
    log_error "[podman] Failed to get Ubuntu version information"
    return 1
fi

if ! curl -fsSL "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo_exec gpg --dearmor -o /etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg; then
    log_error "[podman] Failed to add repository key"
    return 1
fi

# Add the repository
log_info "[podman] Adding Podman repository..."
if ! echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo_exec tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null; then
    log_error "[podman] Failed to add repository"
    return 1
fi

# Update package lists
log_info "[podman] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[podman] Failed to update package lists"
    return 1
fi

# Install Podman
log_info "[podman] Installing Podman and dependencies..."
if ! sudo_exec apt-get install -y podman; then
    log_error "[podman] Failed to install Podman"
    return 1
fi

# Configure basic settings
log_info "[podman] Configuring Podman..."

# Create default storage configuration
if ! sudo_exec mkdir -p /etc/containers/storage.conf.d; then
    log_warn "[podman] Failed to create storage configuration directory"
fi

if ! echo "$STORAGE_CONF" | sudo_exec tee /etc/containers/storage.conf >/dev/null; then
    log_warn "[podman] Failed to create storage configuration"
fi

# Enable and start Podman socket for API compatibility
log_info "[podman] Enabling Podman socket..."
if ! systemctl --user enable podman.socket; then
    log_warn "[podman] Failed to enable Podman socket"
fi

if ! systemctl --user start podman.socket; then
    log_warn "[podman] Failed to start Podman socket"
fi

# Verify installation
if command -v podman &>/dev/null; then
    log_success "[podman] Podman installed successfully"
    podman version
    return 0
else
    log_error "[podman] Podman installation could not be verified"
    return 1
fi