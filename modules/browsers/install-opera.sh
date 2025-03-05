#!/usr/bin/env bash
#
# Opera Browser Installation
# ------------------------
# Installs Opera web browser using official repository
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Opera is already installed
if command -v opera &>/dev/null; then
    log_warn "[opera] Opera browser is already installed"
    opera --version
    return 0
fi

log_info "[opera] Installing Opera browser..."

# Create keyrings directory
sudo_exec mkdir -p /usr/share/keyrings

# Add Opera repository key
log_info "[opera] Adding Opera repository key..."
if ! wget -qO- https://deb.opera.com/archive.key | sudo_exec gpg --dearmor -o /usr/share/keyrings/opera-archive-keyring.gpg; then
    log_error "[opera] Failed to download or import repository key"
    return 1
fi

# Add Opera repository
log_info "[opera] Adding Opera repository..."
if ! echo "deb [signed-by=/usr/share/keyrings/opera-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo_exec tee /etc/apt/sources.list.d/opera.list > /dev/null; then
    log_error "[opera] Failed to add repository"
    return 1
fi

# Update package lists
log_info "[opera] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[opera] Failed to update package lists"
    return 1
fi

# Install Opera
log_info "[opera] Installing Opera browser..."
if ! sudo_exec apt-get install -y opera-stable; then
    log_error "[opera] Failed to install Opera"
    return 1
fi

# Verify installation
if command -v opera &>/dev/null; then
    log_success "[opera] Opera browser installed successfully"
    opera --version
    return 0
else
    log_error "[opera] Opera installation could not be verified"
    return 1
fi