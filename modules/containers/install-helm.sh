#!/usr/bin/env bash
#
# Helm Installation
# ---------------
# Installs Helm - The Kubernetes Package Manager
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Helm is already installed
if command -v helm &>/dev/null; then
    log_warn "[helm] Helm is already installed"
    helm version
    return 0
fi

log_info "[helm] Installing Helm..."

# Install dependencies
log_info "[helm] Installing dependencies..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y curl apt-transport-https gnupg; then
    log_error "[helm] Failed to install dependencies"
    return 1
fi

# Create keyrings directory
sudo_exec mkdir -p /usr/share/keyrings

# Add Helm GPG key
log_info "[helm] Adding Helm repository key..."
if ! curl -fsSL https://baltocdn.com/helm/signing.asc | sudo_exec gpg --dearmor -o /usr/share/keyrings/helm.gpg; then
    log_error "[helm] Failed to add Helm repository key"
    return 1
fi

# Add Helm repository
log_info "[helm] Adding Helm repository..."
if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo_exec tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null; then
    log_error "[helm] Failed to add Helm repository"
    return 1
fi

# Update package lists and install Helm
log_info "[helm] Installing Helm package..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y helm; then
    log_error "[helm] Failed to install Helm"
    return 1
fi

# Initialize Helm and add common repositories
log_info "[helm] Initializing Helm..."

# Create Helm configuration directory
if ! mkdir -p "$HOME/.helm"; then
    log_warn "[helm] Failed to create Helm configuration directory"
fi

# Add popular Helm repositories
log_info "[helm] Adding common Helm repositories..."
if ! helm repo add stable https://charts.helm.sh/stable; then
    log_warn "[helm] Failed to add stable repository"
fi

if ! helm repo add bitnami https://charts.bitnami.com/bitnami; then
    log_warn "[helm] Failed to add bitnami repository"
fi

if ! helm repo update; then
    log_warn "[helm] Failed to update repositories"
fi

# Verify installation
if command -v helm &>/dev/null; then
    log_success "[helm] Helm installed successfully"
    helm version
    
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
    return 0
else
    log_error "[helm] Helm installation could not be verified"
    return 1
fi