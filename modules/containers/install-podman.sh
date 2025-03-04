#!/usr/bin/env bash
#
# Podman Installation
# -----------------
# Installs Podman container engine
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[podman] Installing Podman..."

# Check if Podman is already installed
if ! command -v podman &> /dev/null; then
    # Add kubic repository for latest Podman
    log_info "[podman] Adding Podman repository..."
    
    # Install required packages
    sudo apt-get update
    sudo apt-get install -y curl gpg
    
    # Add the repository key
    source /etc/os-release
    UBUNTU_RELEASE="$VERSION_CODENAME"
    curl -fsSL "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg
    
    # Add the repository
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    
    # Update package lists
    sudo apt-get update
    
    # Install Podman
    log_info "[podman] Installing Podman and dependencies..."
    sudo apt-get install -y podman
    
    # Configure basic settings
    log_info "[podman] Configuring Podman..."
    
    # Create default storage configuration
    sudo mkdir -p /etc/containers/storage.conf.d
    echo '[storage]
driver = "overlay"
runroot = "/run/containers/storage"
graphroot = "/var/lib/containers/storage"
[storage.options]
additionalimagestores = []' | sudo tee /etc/containers/storage.conf
    
    # Enable and start Podman socket for API compatibility
    log_info "[podman] Enabling Podman socket..."
    systemctl --user enable podman.socket || true
    systemctl --user start podman.socket || true
    
    log_success "[podman] Podman installed successfully!"
else
    log_warn "[podman] Podman is already installed."
fi

# Display Podman version
podman version