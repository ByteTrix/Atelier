#!/usr/bin/env bash
#
# Microsoft Edge Installation
# ------------------------
# Installs Microsoft Edge browser using official repository
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[edge] Installing Microsoft Edge browser..."

# Check if Edge is already installed
if ! command -v microsoft-edge-stable &> /dev/null; then
    log_info "[edge] Adding Microsoft Edge repository..."
    
    # Download and add the signing key
    curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
    
    # Add the repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    
    # Update package lists
    log_info "[edge] Updating package lists..."
    sudo apt-get update
    
    # Install Edge
    log_info "[edge] Installing Microsoft Edge browser..."
    sudo apt-get install -y microsoft-edge-stable
    
    log_success "[edge] Microsoft Edge browser installed successfully!"
else
    log_warn "[edge] Microsoft Edge browser is already installed."
fi