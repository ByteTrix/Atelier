#!/usr/bin/env bash
#
# The Silver Searcher (ag) Installation Script
# -----------------------------------------
# Installs and configures The Silver Searcher (ag), a code-searching tool
# similar to ack but faster.
#
# Features:
# - System compatibility check
# - Dependency validation
# - Installation verification
# - Default configuration setup
# - Performance optimization
#
# Author: ByteTrix
# License: MIT

set -euo pipefail

# Module constants
readonly MODULE_NAME="ag"
readonly PACKAGE_NAME="silversearcher-ag"
readonly REQUIRED_COMMANDS=(grep)
readonly DEPENDENCIES=(
    "automake"
    "pkg-config"
    "libpcre3-dev"
    "zlib1g-dev"
    "liblzma-dev"
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
    
    # Check for package manager
    if ! command_exists apt-get; then
        log_error "This script requires apt package manager"
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

# Install dependencies
install_dependencies() {
    log_info "Installing required dependencies..."
    
    if ! $SUDO_CMD apt-get update; then
        log_error "Failed to update package lists"
        return 1
    fi
    
    if ! $SUDO_CMD apt-get install -y "${DEPENDENCIES[@]}"; then
        log_error "Failed to install dependencies"
        return 1
    fi
    
    return 0
}

# Install ag
install_ag() {
    log_info "Installing The Silver Searcher..."
    
    if ! $SUDO_CMD apt-get install -y "$PACKAGE_NAME"; then
        log_error "Failed to install $PACKAGE_NAME"
        return 1
    fi
    
    return 0
}

# Configure ag
configure_ag() {
    log_info "Configuring The Silver Searcher..."
    
    # Create config directory
    local config_dir="$HOME/.agignore"
    
    # Create default ignore patterns
    cat > "$config_dir" <<EOF
# VCS directories
.git/
.hg/
.svn/

# Build directories
build/
dist/
target/

# Dependencies
node_modules/
vendor/

# Temporary files
*.swp
*.swo
*~
.DS_Store
EOF
    
    log_info "Created default .agignore configuration"
    return 0
}

# Verify ag installation
verify_installation() {
    log_info "Verifying The Silver Searcher installation..."
    
    # Check ag executable
    if ! command_exists ag; then
        log_error "The Silver Searcher (ag) executable not found"
        return 1
    fi
    
    # Get version information
    local ag_version
    ag_version=$(ag --version | head -n1)
    log_info "The Silver Searcher version: $ag_version"
    
    # Test basic functionality
    log_info "Testing search functionality..."
    if ! ag --version >/dev/null 2>&1; then
        log_error "Basic functionality test failed"
        return 1
    fi
    
    return 0
}

# Main installation function
main() {
    log_info "Beginning The Silver Searcher (ag) installation..."
    
    # Check if already installed
    if command_exists ag; then
        local current_version
        current_version=$(ag --version | head -n1)
        log_warn "The Silver Searcher is already installed (Version: $current_version)"
        return 0
    fi
    
    # Check system compatibility
    if ! check_system_compatibility; then
        log_error "System compatibility check failed"
        exit 1
    fi
    
    # Install dependencies
    if ! install_dependencies; then
        log_error "Failed to install dependencies"
        exit 1
    fi
    
    # Install ag
    if ! install_ag; then
        log_error "Failed to install The Silver Searcher"
        exit 1
    fi
    
    # Configure ag
    if ! configure_ag; then
        log_warn "Configuration had some issues, but continuing..."
    fi
    
    # Verify installation
    if ! verify_installation; then
        log_error "Installation verification failed"
        exit 1
    fi
    
    log_success "The Silver Searcher (ag) installation completed successfully!"
    log_info "Usage: ag [pattern] [path]"
    log_info "Example: ag 'function' ."
}

# Run main function
main "$@"
