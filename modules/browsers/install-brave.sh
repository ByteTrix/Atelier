#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Brave is already installed
if command -v brave-browser &>/dev/null; then
    log_warn "[browsers] Brave Browser is already installed"
    brave-browser --version
    return 0
fi

log_info "[browsers] Installing Brave Browser..."

# Install dependencies
log_info "[browsers] Installing dependencies..."
if ! sudo_exec apt-get install -y apt-transport-https curl; then
    log_error "[browsers] Failed to install dependencies"
    return 1
fi

# Add Brave repository key
log_info "[browsers] Adding Brave repository key..."
if ! sudo_exec curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
    log_error "[browsers] Failed to download Brave repository key"
    return 1
fi

# Add Brave repository
log_info "[browsers] Adding Brave repository..."
if ! echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo_exec tee /etc/apt/sources.list.d/brave-browser-release.list; then
    log_error "[browsers] Failed to add Brave repository"
    return 1
fi

# Update package lists
log_info "[browsers] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[browsers] Failed to update package lists"
    return 1
fi

# Install Brave
log_info "[browsers] Installing Brave browser..."
if ! sudo_exec apt-get install -y brave-browser; then
    log_error "[browsers] Failed to install Brave browser"
    return 1
fi

# Verify installation
if command -v brave-browser &>/dev/null; then
    log_success "[browsers] Brave Browser installed successfully"
    brave-browser --version
    return 0
else
    log_error "[browsers] Brave Browser installation could not be verified"
    return 1
fi
