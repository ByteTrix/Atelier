#!/usr/bin/env bash
#
# Minikube Installation
# -------------------
# Installs Minikube for local Kubernetes development
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Minikube is already installed
if command -v minikube &>/dev/null; then
    log_warn "[minikube] Minikube is already installed"
    minikube version
    log_info "[minikube] Current status:"
    minikube status || true
    return 0
fi

log_info "[minikube] Installing Minikube..."

# Install required dependencies
log_info "[minikube] Installing dependencies..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y curl virtualbox virtualbox-ext-pack; then
    log_error "[minikube] Failed to install dependencies"
    return 1
fi

# Create temp directory for downloads
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || {
    log_error "[minikube] Failed to create temporary directory"
    return 1
}

# Download Minikube binary
log_info "[minikube] Downloading Minikube..."
if ! curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64; then
    log_error "[minikube] Failed to download Minikube"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Install Minikube
log_info "[minikube] Installing Minikube..."
if ! sudo_exec install minikube-linux-amd64 /usr/local/bin/minikube; then
    log_error "[minikube] Failed to install Minikube"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Cleanup
cd - &>/dev/null || true
rm -rf "$TEMP_DIR"

# Configure Minikube
log_info "[minikube] Configuring Minikube..."

# Set VirtualBox as default driver
if ! minikube config set driver virtualbox; then
    log_warn "[minikube] Failed to set VirtualBox driver, continuing anyway..."
fi

# Set default memory allocation (4GB)
if ! minikube config set memory 4096; then
    log_warn "[minikube] Failed to set memory allocation, continuing anyway..."
fi

# Set default CPU allocation (2 CPUs)
if ! minikube config set cpus 2; then
    log_warn "[minikube] Failed to set CPU allocation, continuing anyway..."
fi

# Enable commonly used addons
log_info "[minikube] Enabling default addons..."
for addon in dashboard metrics-server ingress; do
    if ! minikube addons enable "$addon"; then
        log_warn "[minikube] Failed to enable $addon addon, continuing anyway..."
    fi
done

# Create default Kubernetes context
log_info "[minikube] Creating initial Kubernetes context..."
if ! minikube start; then
    log_warn "[minikube] Failed to start Minikube cluster, you may need to start it manually"
fi

# Verify installation
if command -v minikube &>/dev/null; then
    log_success "[minikube] Minikube installed successfully"
    minikube version
    
    # Display help information
    log_info "[minikube] Quick start guide:"
    echo "
    - Start Minikube: minikube start
    - Stop Minikube: minikube stop
    - Access Dashboard: minikube dashboard
    - Delete cluster: minikube delete
    - Get cluster info: minikube status
    "
    return 0
else
    log_error "[minikube] Minikube installation could not be verified"
    return 1
fi