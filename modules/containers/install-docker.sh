#!/usr/bin/env bash
#
# Docker Installation Script
# ------------------------
# Installs Docker Engine on Ubuntu systems following official installation
# method, including repository setup and GPG key management.
#
# Features:
# - Full Docker Engine installation
# - Repository and GPG key setup
# - User permission configuration
# - System compatibility verification
# - Installation validation
#
# Author: ByteTrix
# License: MIT

set -euo pipefail

# Module constants
readonly MODULE_NAME="docker"
readonly REQUIRED_COMMANDS=(curl gpg lsb_release)
readonly DOCKER_GPG_KEY_URL="https://download.docker.com/linux/ubuntu/gpg"
readonly DOCKER_REPOSITORY="https://download.docker.com/linux/ubuntu"

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
    
    # Check OS
    if [ ! -f /etc/os-release ]; then
        log_error "Could not determine OS version"
        return 1
    fi
    
    # Verify Ubuntu
    if ! grep -qi "ubuntu" /etc/os-release; then
        log_error "This script is designed for Ubuntu systems only"
        return 1
    fi
    
    # Check architecture
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            log_info "Architecture $arch supported"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    return 0
}

# Check for required dependencies
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

# Setup Docker repository
setup_repository() {
    log_info "Setting up Docker repository..."
    
    # Install required packages for repository setup
    $SUDO_CMD apt-get update
    $SUDO_CMD apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Create directory for keyrings
    $SUDO_CMD mkdir -p /etc/apt/keyrings
    
    # Download and add Docker's official GPG key
    curl -fsSL "$DOCKER_GPG_KEY_URL" | \
        $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        $DOCKER_REPOSITORY \
        $(lsb_release -cs) stable" | \
        $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index
    $SUDO_CMD apt-get update
}

# Install Docker packages
install_docker() {
    log_info "Installing Docker Engine..."
    
    # Install Docker packages
    if ! $SUDO_CMD apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin; then
        log_error "Failed to install Docker packages"
        return 1
    fi
    
    return 0
}

# Configure Docker
configure_docker() {
    log_info "Configuring Docker..."
    
    # Enable Docker service
    if ! $SUDO_CMD systemctl enable --now docker; then
        log_error "Failed to enable Docker service"
        return 1
    fi
    
    # Add user to docker group
    if ! $SUDO_CMD usermod -aG docker "$USER"; then
        log_warn "Failed to add user to docker group"
        log_warn "You may need to use sudo with docker commands"
    fi
    
    # Create default Docker config directory
    mkdir -p "$HOME/.docker"
    
    return 0
}

# Verify Docker installation
verify_installation() {
    log_info "Verifying Docker installation..."
    
    # Check Docker CLI
    if ! command_exists docker; then
        log_error "Docker CLI not found"
        return 1
    fi
    
    # Check Docker service
    if ! $SUDO_CMD systemctl is-active --quiet docker; then
        log_error "Docker service is not running"
        return 1
    fi
    
    # Print version information
    log_info "Docker version information:"
    docker --version
    docker compose version
    
    return 0
}

# Main installation function
main() {
    log_info "Beginning Docker installation..."
    
    if ! check_system_compatibility; then
        log_error "System compatibility check failed"
        exit 1
    fi
    
    if ! check_dependencies; then
        log_error "Dependency check failed"
        exit 1
    fi
    
    if ! setup_repository; then
        log_error "Failed to setup Docker repository"
        exit 1
    fi
    
    if ! install_docker; then
        log_error "Docker installation failed"
        exit 1
    fi
    
    if ! configure_docker; then
        log_warn "Docker configuration had some issues, but continuing..."
    fi
    
    if ! verify_installation; then
        log_error "Docker installation verification failed"
        exit 1
    fi
    
    log_success "Docker installation completed successfully!"
    log_info "NOTE: You may need to log out and back in for group changes to take effect"
}

# Run main function
main "$@"
