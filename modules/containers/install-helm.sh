#!/usr/bin/env bash
#
# Helm Installation
# ---------------
# Installs Helm - The Kubernetes Package Manager
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[helm] Installing Helm..."

# Check if Helm is already installed
if ! command -v helm &> /dev/null; then
    # Install dependencies
    log_info "[helm] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y curl apt-transport-https

    # Add Helm GPG key and repository
    log_info "[helm] Adding Helm repository..."
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

    # Update package lists and install Helm
    sudo apt-get update
    sudo apt-get install -y helm

    # Initialize Helm and add common repositories
    log_info "[helm] Initializing Helm..."
    
    # Add popular Helm repositories
    log_info "[helm] Adding common Helm repositories..."
    helm repo add stable https://charts.helm.sh/stable
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

    # Create Helm configuration directory
    mkdir -p "$HOME/.helm"

    log_success "[helm] Helm installed successfully!"

    # Display help information
    log_info "[helm] Quick start guide:"
    echo "
    - Search charts: helm search repo <keyword>
    - Add repository: helm repo add <name> <url>
    - Update repositories: helm repo update
    - Install chart: helm install <release-name> <chart>
    - List releases: helm list
    - Uninstall release: helm uninstall <release-name>
    "
else
    log_warn "[helm] Helm is already installed."
fi

# Display version information
helm version