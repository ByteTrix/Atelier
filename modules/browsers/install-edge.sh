#!/usr/bin/env bash
#
# Microsoft Edge Installation
# ------------------------
# Installs Microsoft Edge browser using official repository
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Edge is already installed
if command -v microsoft-edge-stable &>/dev/null; then
    log_warn "[edge] Microsoft Edge browser is already installed"
    microsoft-edge-stable --version
    return 0
fi

log_info "[edge] Installing Microsoft Edge browser..."

# Create keyrings directory if it doesn't exist
sudo_exec mkdir -p /usr/share/keyrings

# Download and add the signing key
log_info "[edge] Adding Microsoft Edge repository key..."
if ! curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo_exec gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg; then
    log_error "[edge] Failed to download or import repository key"
    return 1
fi

# Add the repository
log_info "[edge] Adding Microsoft Edge repository..."
if ! echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo_exec tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null; then
    log_error "[edge] Failed to add repository"
    return 1
fi

# Update package lists
log_info "[edge] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[edge] Failed to update package lists"
    return 1
fi

# Install Edge
log_info "[edge] Installing Microsoft Edge browser..."
if ! sudo_exec apt-get install -y microsoft-edge-stable; then
    log_error "[edge] Failed to install Microsoft Edge"
    return 1
fi

# Verify installation
if command -v microsoft-edge-stable &>/dev/null; then
    log_success "[edge] Microsoft Edge browser installed successfully"
    microsoft-edge-stable --version
    return 0
else
    log_error "[edge] Microsoft Edge installation could not be verified"
    return 1
fi