#!/usr/bin/env bash
#
# HTTPie Installation
# -----------------
# Installs HTTPie, a user-friendly command-line HTTP client
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[httpie] Installing HTTPie..."

# Check if HTTPie is already installed
if ! command -v http &> /dev/null; then
    log_info "[httpie] Installing HTTPie via pip..."
    
    # Ensure pip is installed
    if ! command -v pip3 &> /dev/null; then
        log_info "[httpie] Installing python3-pip..."
        sudo apt-get update
        sudo apt-get install -y python3-pip
    fi
    
    # Install HTTPie
    pip3 install --user httpie
    
    # Add local bin to PATH if not already present
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    log_success "[httpie] HTTPie installed successfully!"
else
    log_warn "[httpie] HTTPie is already installed."
fi