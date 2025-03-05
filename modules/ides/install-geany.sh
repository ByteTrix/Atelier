#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Geany is already installed
if command -v geany &>/dev/null; then
    log_warn "[ides] Geany is already installed"
    geany --version
    return 0
fi

log_info "[ides] Installing Geany IDE..."

# Update package lists
if ! sudo_exec apt-get update; then
    log_error "[ides] Failed to update package lists"
    return 1
fi

# Install Geany
if ! sudo_exec apt-get install -y geany; then
    log_error "[ides] Failed to install Geany"
    return 1
fi

# Verify installation
if command -v geany &>/dev/null; then
    log_success "[ides] Geany installed successfully"
    geany --version
    
    # Display help information
    log_info "[ides] Quick start guide:"
    echo "
    - Launch: geany
    - Open file: geany filename
    - Create new file: Ctrl+N
    - Save: Ctrl+S
    - Build: F9
    - Run: F5
    - Popular plugins to consider:
      * Git Change Bar
      * Split Window
      * Project Organizer
      * Code Navigation
    "
    return 0
else
    log_error "[ides] Geany installation could not be verified"
    return 1
fi
