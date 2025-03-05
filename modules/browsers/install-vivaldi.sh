#!/usr/bin/env bash
#
# Vivaldi Browser Installation
# --------------------------
# Installs Vivaldi web browser using official repository
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Vivaldi is already installed
if command -v vivaldi-stable &>/dev/null; then
    log_warn "[vivaldi] Vivaldi browser is already installed"
    vivaldi-stable --version
    return 0
fi

log_info "[vivaldi] Installing Vivaldi browser..."

# Create keyrings directory
sudo_exec mkdir -p /usr/share/keyrings

# Download and add the signing key
log_info "[vivaldi] Adding Vivaldi repository key..."
if ! wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo_exec gpg --dearmor -o /usr/share/keyrings/vivaldi-archive-keyring.gpg; then
    log_error "[vivaldi] Failed to download or import repository key"
    return 1
fi

# Add the repository
log_info "[vivaldi] Adding Vivaldi repository..."
if ! echo "deb [signed-by=/usr/share/keyrings/vivaldi-archive-keyring.gpg] https://repo.vivaldi.com/archive/deb/ stable main" | sudo_exec tee /etc/apt/sources.list.d/vivaldi.list > /dev/null; then
    log_error "[vivaldi] Failed to add repository"
    return 1
fi

# Update package lists
log_info "[vivaldi] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[vivaldi] Failed to update package lists"
    return 1
fi

# Install Vivaldi
log_info "[vivaldi] Installing Vivaldi browser..."
if ! sudo_exec apt-get install -y vivaldi-stable; then
    log_error "[vivaldi] Failed to install Vivaldi"
    return 1
fi

# Verify installation
if command -v vivaldi-stable &>/dev/null; then
    log_success "[vivaldi] Vivaldi browser installed successfully"
    vivaldi-stable --version
    return 0
else
    log_error "[vivaldi] Vivaldi installation could not be verified"
    return 1
fi