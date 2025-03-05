#!/usr/bin/env bash
#
# Google Chrome Installation Script
# ------------------------------
# Installs Google Chrome browser with secure repository setup
# and proper system integration.
#
# Features:
# - Secure GPG key handling
# - Architecture validation
# - Desktop integration
# - Default configuration
# - Installation verification
# - Dependency management
#
# Author: ByteTrix
# License: MIT

set -euo pipefail

# Module constants
readonly MODULE_NAME="chrome"
readonly PACKAGE_NAME="google-chrome-stable"
readonly REQUIRED_COMMANDS=(curl gpg)
readonly CHROME_GPG_KEY_URL="https://dl-ssl.google.com/linux/linux_signing_key.pub"
readonly CHROME_REPO_URL="http://dl.google.com/linux/chrome/deb/"

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
    
    # Check architecture
    local arch
    arch=$(dpkg --print-architecture)
    if [ "$arch" != "amd64" ]; then
        log_error "Google Chrome is only available for 64-bit (amd64) systems"
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

# Setup Chrome repository
setup_repository() {
    log_info "Setting up Google Chrome repository..."
    
    # Install required packages
    if ! $SUDO_CMD apt-get update && \
       ! $SUDO_CMD apt-get install -y curl apt-transport-https ca-certificates gnupg; then
        log_error "Failed to install required packages"
        return 1
    fi
    
    # Create keyrings directory
    $SUDO_CMD mkdir -p /usr/share/keyrings
    
    # Download and verify Google's signing key
    if ! curl -fsSL "$CHROME_GPG_KEY_URL" | \
         $SUDO_CMD gpg --dearmor -o /usr/share/keyrings/google-chrome-archive-keyring.gpg; then
        log_error "Failed to import Google Chrome GPG key"
        return 1
    fi
    
    # Add Chrome repository with secure configuration
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] $CHROME_REPO_URL stable main" | \
        $SUDO_CMD tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
    
    # Update package lists
    if ! $SUDO_CMD apt-get update; then
        log_error "Failed to update package lists"
        return 1
    fi
    
    return 0
}

# Install Chrome browser
install_chrome() {
    log_info "Installing Google Chrome..."
    
    if ! $SUDO_CMD apt-get install -y "$PACKAGE_NAME"; then
        log_error "Failed to install Google Chrome"
        return 1
    fi
    
    return 0
}

# Configure Chrome defaults
configure_chrome() {
    log_info "Configuring Google Chrome..."
    
    local chrome_policies="/etc/opt/chrome/policies/managed"
    local chrome_defaults="/etc/opt/chrome/policies/recommended"
    
    # Create policy directories
    $SUDO_CMD mkdir -p "$chrome_policies" "$chrome_defaults"
    
    # Setup managed policies (required settings)
    local managed_policy='{
        "AutoUpdateCheckPeriodMinutes": 1440,
        "DefaultBrowserSettingEnabled": false,
        "MetricsReportingEnabled": false
    }'
    echo "$managed_policy" | $SUDO_CMD tee "$chrome_policies/policy.json" > /dev/null
    
    # Setup recommended policies (user-adjustable settings)
    local recommended_policy='{
        "RestoreOnStartup": 1,
        "HomepageLocation": "https://www.google.com",
        "BlockThirdPartyCookies": true
    }'
    echo "$recommended_policy" | $SUDO_CMD tee "$chrome_defaults/policy.json" > /dev/null
    
    return 0
}

# Verify Chrome installation
verify_installation() {
    log_info "Verifying Google Chrome installation..."
    
    # Check Chrome executable
    if ! command_exists google-chrome; then
        log_error "Google Chrome executable not found"
        return 1
    fi
    
    # Check desktop integration
    if [ ! -f "/usr/share/applications/google-chrome.desktop" ]; then
        log_warn "Desktop integration file not found"
    fi
    
    # Print version information
    local chrome_version
    chrome_version=$(google-chrome --version)
    log_info "Google Chrome version: $chrome_version"
    
    return 0
}

# Main installation function
main() {
    log_info "Beginning Google Chrome installation..."
    
    # Check if already installed
    if command_exists google-chrome; then
        local current_version
        current_version=$(google-chrome --version)
        log_warn "Google Chrome is already installed (Version: $current_version)"
        return 0
    fi
    
    # Check system compatibility
    if ! check_system_compatibility; then
        log_error "System compatibility check failed"
        return 1
    fi
    
    # Setup repository
    if ! setup_repository; then
        log_error "Repository setup failed"
        return 1
    fi
    
    # Install Chrome
    if ! install_chrome; then
        log_error "Chrome installation failed"
        return 1
    fi
    
    # Configure Chrome
    if ! configure_chrome; then
        log_warn "Chrome configuration had some issues, but continuing..."
    fi
    
    # Verify installation
    if ! verify_installation; then
        log_error "Installation verification failed"
        return 1
    fi
    
    log_success "Google Chrome installation completed successfully!"
}

# Run main function
main "$@"
