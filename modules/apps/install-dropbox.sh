#!/usr/bin/env bash
#
# Dropbox Installer
# ---------------
# Installs the Dropbox cloud storage client
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps/dropbox] Installing Dropbox cloud storage client..."

# Check if already installed
if command -v dropbox &>/dev/null; then
    log_info "[apps/dropbox] Dropbox is already installed"
    exit 0
fi

# Add repository if needed
if ! apt-cache policy | grep -q "dropbox"; then
    log_info "[apps/dropbox] Adding Dropbox repository..."
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
    echo "deb [arch=amd64] http://linux.dropbox.com/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/dropbox.list
    sudo apt update
fi

# Install Dropbox
log_info "[apps/dropbox] Installing Dropbox package..."
if ! sudo apt install -y dropbox; then
    log_error "[apps/dropbox] Failed to install Dropbox"
    exit 1
fi

log_info "[apps/dropbox] Dropbox installed successfully"
log_info "[apps/dropbox] Run 'dropbox start -i' to complete setup"
