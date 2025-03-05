#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Emacs is already installed
if command -v emacs &>/dev/null; then
    log_warn "[ides] GNU Emacs is already installed"
    emacs --version
    return 0
fi

log_info "[ides] Installing GNU Emacs..."

# Update package lists
if ! sudo_exec apt-get update; then
    log_error "[ides] Failed to update package lists"
    return 1
fi

# Install Emacs
if ! sudo_exec apt-get install -y emacs; then
    log_error "[ides] Failed to install GNU Emacs"
    return 1
fi

# Create basic configuration directory
if ! mkdir -p "$HOME/.emacs.d"; then
    log_warn "[ides] Failed to create Emacs configuration directory"
fi

# Verify installation
if command -v emacs &>/dev/null; then
    log_success "[ides] GNU Emacs installed successfully"
    emacs --version
    
    # Display help information
    log_info "[ides] Quick start guide:"
    echo "
    - Launch: emacs
    - Exit: Ctrl+x Ctrl+c
    - Save: Ctrl+x Ctrl+s
    - Open file: Ctrl+x Ctrl+f
    - Tutorial: Ctrl+h t
    - Package management: M-x package-list-packages
    - Popular packages to consider:
      * company (completion)
      * magit (git interface)
      * projectile (project management)
      * which-key (key binding help)
    "
    return 0
else
    log_error "[ides] GNU Emacs installation could not be verified"
    return 1
fi
