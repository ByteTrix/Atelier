#!/usr/bin/env bash
#
# Node.js Installation Script
# -------------------------
# Installs Node.js using the official NodeSource repository.
#
# Features:
# - LTS or specific version installation
# - Secure GPG key handling
# - Global npm configuration
# - Dev dependencies installation
# - Installation verification
# - System compatibility check
#
# Author: ByteTrix
# License: MIT

set -euo pipefail

# Module constants
readonly MODULE_NAME="node"
readonly NODE_VERSION="${NODE_VERSION:-lts}"  # Can be overridden with env var
readonly REQUIRED_COMMANDS=(curl gpg)
readonly NODESOURCE_GPG_KEY="https://deb.nodesource.com/gpgkey/nodesource.gpg.key"
readonly DEFAULT_NPM_PACKAGES=(
    "npm@latest"
    "yarn"
    "typescript"
    "node-gyp"
)

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Determine sudo command based on environment
SUDO_CMD="sudo"
if [[ "${SETUPR_SUDO:-0}" == "1" ]]; then
    SUDO_CMD="sudo_exec"
fi

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system compatibility
check_system_compatibility() {
    log_info "Checking system compatibility..."
    
    # Check for supported OS
    if [ ! -f /etc/os-release ]; then
        log_error "Could not determine OS version"
        return 1
    fi
    
    # Check for required commands
    local missing_deps=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# Setup NodeSource repository
setup_repository() {
    log_info "Setting up NodeSource repository..."
    
    # Create temp directory for setup
    local temp_dir
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT
    
    # Download and verify GPG key
    if ! curl -fsSL "$NODESOURCE_GPG_KEY" -o "$temp_dir/nodesource.gpg"; then
        log_error "Failed to download NodeSource GPG key"
        return 1
    fi
    
    # Import GPG key
    if ! $SUDO_CMD gpg --dearmor -o /usr/share/keyrings/nodesource.gpg < "$temp_dir/nodesource.gpg"; then
        log_error "Failed to import NodeSource GPG key"
        return 1
    fi
    
    # Download setup script
    local setup_script="$temp_dir/setup.sh"
    if [ "$NODE_VERSION" = "lts" ]; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x -o "$setup_script"
    else
        curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" -o "$setup_script"
    fi
    
    # Run setup script
    if ! $SUDO_CMD bash "$setup_script"; then
        log_error "Failed to setup NodeSource repository"
        return 1
    fi
    
    return 0
}

# Install Node.js and dependencies
install_node() {
    log_info "Installing Node.js..."
    
    # Install Node.js and essential build tools
    if ! $SUDO_CMD apt-get install -y nodejs build-essential; then
        log_error "Failed to install Node.js"
        return 1
    fi
    
    return 0
}

# Configure npm globally
configure_npm() {
    log_info "Configuring npm..."
    
    # Create global npm directory in user's home
    local npm_global_dir="$HOME/.npm-global"
    mkdir -p "$npm_global_dir"
    
    # Set npm global path
    if ! npm config set prefix "$npm_global_dir"; then
        log_warn "Failed to set npm global prefix"
        return 1
    fi
    
    # Add npm global bin to PATH in profile
    local profile="$HOME/.profile"
    if ! grep -q "NPM_GLOBAL" "$profile"; then
        echo "export PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$profile"
    fi
    
    # Install global packages
    log_info "Installing global npm packages..."
    for package in "${DEFAULT_NPM_PACKAGES[@]}"; do
        if ! npm install -g "$package"; then
            log_warn "Failed to install global package: $package"
        fi
    done
    
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying Node.js installation..."
    
    # Check Node.js
    if ! command_exists node; then
        log_error "Node.js installation verification failed"
        return 1
    fi
    
    # Check npm
    if ! command_exists npm; then
        log_error "npm installation verification failed"
        return 1
    fi
    
    # Display version information
    log_info "Installation verified successfully:"
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
    
    return 0
}

# Main installation function
main() {
    log_info "Beginning Node.js installation..."
    
    # Check if already installed
    if command_exists node; then
        local current_version
        current_version=$(node --version)
        log_warn "Node.js is already installed (Version: $current_version)"
        log_info "To reinstall, please remove existing installation first"
        return 0
    fi
    
    # Check system compatibility
    if ! check_system_compatibility; then
        log_error "System compatibility check failed"
        exit 1
    fi
    
    # Setup repository
    if ! setup_repository; then
        log_error "Repository setup failed"
        exit 1
    fi
    
    # Install Node.js
    if ! install_node; then
        log_error "Node.js installation failed"
        exit 1
    fi
    
    # Configure npm
    if ! configure_npm; then
        log_warn "npm configuration had some issues, but continuing..."
    fi
    
    # Verify installation
    if ! verify_installation; then
        log_error "Installation verification failed"
        exit 1
    fi
    
    log_success "Node.js installation completed successfully!"
    log_info "Please log out and back in for PATH changes to take effect"
}

# Run main function
main "$@"
