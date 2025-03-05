#!/usr/bin/env bash
#
# Dropbox Installer
# ---------------
# Installs the Dropbox cloud storage client
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps/dropbox] Installing Dropbox cloud storage client..."

# Check if already installed
if command -v dropbox &>/dev/null; then
    log_warn "[apps/dropbox] Dropbox is already installed"
    dropbox version || true
    return 0
fi

# Add repository if needed
if ! apt-cache policy | grep -q "dropbox"; then
    log_info "[apps/dropbox] Adding Dropbox repository..."
    
    # Add repository key
    if ! sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E; then
        log_error "[apps/dropbox] Failed to add repository key"
        return 1
    fi
    
    # Add repository
    if ! echo "deb [arch=amd64] http://linux.dropbox.com/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/dropbox.list; then
        log_error "[apps/dropbox] Failed to add repository"
        return 1
    fi
    
    # Update package lists
    if ! sudo apt-get update; then
        log_error "[apps/dropbox] Failed to update package lists"
        return 1
    fi
fi

# Install Dropbox
log_info "[apps/dropbox] Installing Dropbox package..."
if ! sudo apt-get install -y dropbox; then
    log_error "[apps/dropbox] Failed to install Dropbox"
    return 1
fi

# Verify installation
if command -v dropbox &>/dev/null; then
    log_success "[apps/dropbox] Dropbox installed successfully"
    log_info "[apps/dropbox] Version information:"
    dropbox version || true
    log_info "[apps/dropbox] Run 'dropbox start -i' to complete setup"
    return 0
else
    log_error "[apps/dropbox] Installation verification failed"
    return 1
fi
