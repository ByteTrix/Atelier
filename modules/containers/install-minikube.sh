#!/usr/bin/env bash
#
# Minikube Installation
# -------------------
# Installs Minikube for local Kubernetes development
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[minikube] Installing Minikube..."

# Check if Minikube is already installed
if ! command -v minikube &> /dev/null; then
    # Install required dependencies
    log_info "[minikube] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y curl virtualbox virtualbox-ext-pack

    # Download Minikube binary
    log_info "[minikube] Downloading Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64

    # Configure Minikube
    log_info "[minikube] Configuring Minikube..."
    
    # Set VirtualBox as default driver
    minikube config set driver virtualbox
    
    # Set default memory allocation (4GB)
    minikube config set memory 4096
    
    # Set default CPU allocation (2 CPUs)
    minikube config set cpus 2
    
    # Enable commonly used addons
    log_info "[minikube] Enabling default addons..."
    minikube addons enable dashboard
    minikube addons enable metrics-server
    minikube addons enable ingress
    
    # Create default Kubernetes context
    log_info "[minikube] Creating initial Kubernetes context..."
    minikube start
    
    log_success "[minikube] Minikube installed and configured successfully!"
    
    # Display help information
    log_info "[minikube] Quick start guide:"
    echo "
    - Start Minikube: minikube start
    - Stop Minikube: minikube stop
    - Access Dashboard: minikube dashboard
    - Delete cluster: minikube delete
    - Get cluster info: minikube status
    "
else
    log_warn "[minikube] Minikube is already installed."
    
    # Display current status
    log_info "[minikube] Current Minikube status:"
    minikube status
fi

# Display version information
minikube version