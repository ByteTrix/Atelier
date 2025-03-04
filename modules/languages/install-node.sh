#!/usr/bin/env bash
#
# Node.js Installation
# -----------------
# Installs Node.js and npm with commonly used global packages
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[node] Installing Node.js and npm..."

# Check if Node.js is already installed
if ! command -v node &> /dev/null; then
    # Install Node.js using NodeSource repository
    log_info "[node] Adding NodeSource repository..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

    # Install Node.js
    log_info "[node] Installing Node.js..."
    sudo apt-get install -y nodejs

    # Install build essentials (required for some npm packages)
    log_info "[node] Installing build essentials..."
    sudo apt-get install -y build-essential

    # Configure npm
    log_info "[node] Configuring npm..."
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    
    # Add npm global path to .bashrc if not already present
    if ! grep -q "npm-global/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.npm-global/bin:$PATH"
    fi

    # Install common global packages
    log_info "[node] Installing common global packages..."
    npm install -g \
        npm@latest \
        yarn \
        typescript \
        ts-node \
        nodemon \
        pm2 \
        npx

    log_success "[node] Node.js and npm installed successfully!"

    # Display help information
    log_info "[node] Quick start guide:"
    echo "
    Node.js:
    - Check version: node --version
    - Run script: node script.js
    - Start REPL: node
    
    npm:
    - Initialize project: npm init
    - Install package: npm install package-name
    - Run scripts: npm run script-name
    - Update packages: npm update
    
    Global packages installed:
    - yarn: Alternative package manager
    - typescript: JavaScript with types
    - ts-node: Run TypeScript files directly
    - nodemon: Auto-reload for development
    - pm2: Process manager for Node.js apps
    
    Environment:
    - Global packages: $HOME/.npm-global
    - Local packages: ./node_modules
    - Configuration: npm config list
    "
else
    log_warn "[node] Node.js is already installed."
fi

# Verify installation
log_info "[node] Verifying installation..."
echo "Node.js version:"
node --version
echo -e "\nnpm version:"
npm --version
