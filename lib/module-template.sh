#!/usr/bin/env bash
#
# Module Installation Template
# --------------------------
# This template provides a standardized structure for Setupr module installation scripts.
# It includes proper error handling, dependency checking, and configuration management.
#
# Usage:
#   1. Copy this template to create a new module
#   2. Replace MODULE_NAME and PACKAGE_NAME variables
#   3. Implement the check_dependencies and install_package functions
#   4. Add any module-specific configuration in configure_package
#
# Author: ByteTrix
# License: MIT

set -euo pipefail

# Module constants
readonly MODULE_NAME="module-name"     # Replace with actual module name
readonly PACKAGE_NAME="package-name"   # Replace with actual package name
readonly REQUIRED_COMMANDS=()          # Add required commands/dependencies

# Get script location
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Determine sudo command based on environment
if [[ "${SETUPR_SUDO:-0}" == "1" ]]; then
    SUDO_CMD="sudo_exec"
else
    SUDO_CMD="sudo"
fi

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check all required dependencies
check_dependencies() {
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

# Verify system compatibility
check_system_compatibility() {
    # Add system checks here (OS version, architecture, etc.)
    if ! command_exists "apt-get"; then
        log_error "This module requires an Ubuntu-based system"
        return 1
    fi
    return 0
}

# Install the package
install_package() {
    log_info "Installing $MODULE_NAME..."
    
    # Add installation steps here
    # Example:
    # if ! $SUDO_CMD apt-get update; then
    #     log_error "Failed to update package lists"
    #     return 1
    # fi
    #
    # if ! $SUDO_CMD apt-get install -y "$PACKAGE_NAME"; then
    #     log_error "Failed to install $PACKAGE_NAME"
    #     return 1
    # fi
    
    return 0
}

# Configure the installed package
configure_package() {
    log_info "Configuring $MODULE_NAME..."
    
    # Add configuration steps here
    # Example:
    # local config_file="/etc/package/config"
    # if [ -f "$config_file" ]; then
    #     backup_file "$config_file"
    #     if ! $SUDO_CMD cp "./config/default.conf" "$config_file"; then
    #         log_error "Failed to configure $MODULE_NAME"
    #         return 1
    #     fi
    # fi
    
    return 0
}

# Verify the installation
verify_installation() {
    log_info "Verifying $MODULE_NAME installation..."
    
    if ! command_exists "$PACKAGE_NAME"; then
        log_error "$MODULE_NAME installation verification failed"
        return 1
    fi
    
    # Add additional verification steps here
    
    return 0
}

# Main installation function
main() {
    log_info "Beginning $MODULE_NAME installation..."
    
    # Check system compatibility
    if ! check_system_compatibility; then
        log_error "System compatibility check failed"
        exit 1
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        log_error "Dependency check failed"
        exit 1
    fi
    
    # Install package
    if ! install_package; then
        log_error "Installation failed"
        exit 1
    fi
    
    # Configure package
    if ! configure_package; then
        log_warn "Configuration had some issues, but continuing..."
    fi
    
    # Verify installation
    if ! verify_installation; then
        log_error "Installation verification failed"
        exit 1
    fi
    
    log_success "$MODULE_NAME installation completed successfully"
}

# Run main function
main "$@"