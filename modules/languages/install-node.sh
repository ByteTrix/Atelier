#!/usr/bin/env bash
#
# Node.js Installation
# -----------------
# Installs Node.js using NodeSource repository
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[node] Installing Node.js..."

# Check if Node.js is already installed
if ! command -v node &> /dev/null; then
    # Add NodeSource repository
    log_info "[node] Adding NodeSource repository..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x > /tmp/nodesource_setup.sh
    sudo_exec bash /tmp/nodesource_setup.sh
    rm -f /tmp/nodesource_setup.sh

    # Install Node.js and build essentials
    log_info "[node] Installing Node.js and dependencies..."
    sudo_exec apt-get install -y nodejs build-essential

    log_success "[node] Node.js installed successfully!"

    # Display version information
    log_info "[node] Version information:"
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
else
    log_warn "[node] Node.js is already installed"
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
fi
