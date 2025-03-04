#!/usr/bin/env bash
#
# Vivaldi Browser Installation
# --------------------------
# Installs Vivaldi web browser using official repository
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[vivaldi] Installing Vivaldi browser..."

# Check if Vivaldi is already installed
if ! command -v vivaldi-stable &> /dev/null; then
    log_info "[vivaldi] Adding Vivaldi repository..."
    
    # Download and add the signing key
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
    
    # Add the repository
    echo "deb https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
    
    # Update package lists
    log_info "[vivaldi] Updating package lists..."
    sudo apt-get update
    
    # Install Vivaldi
    log_info "[vivaldi] Installing Vivaldi browser..."
    sudo apt-get install -y vivaldi-stable
    
    log_success "[vivaldi] Vivaldi browser installed successfully!"
else
    log_warn "[vivaldi] Vivaldi browser is already installed."
fi