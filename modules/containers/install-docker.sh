#!/usr/bin/env bash
#
# Docker Installation
# ------------------
# Installs Docker Engine and enables the service
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Determine sudo command based on environment
if [[ "${SETUPR_SUDO:-0}" == "1" ]]; then
    SUDO_CMD="sudo_exec"
else
    SUDO_CMD="sudo"
fi

log_info "[docker] Installing Docker Engine..."

# Install Docker
$SUDO_CMD apt-get update
$SUDO_CMD apt-get install -y docker.io

# Enable and start Docker service
$SUDO_CMD systemctl enable --now docker

# Add current user to docker group to avoid using sudo for docker commands
$SUDO_CMD usermod -aG docker "$USER"

# Verify installation
if command -v docker &>/dev/null; then
    log_info "[docker] Docker version information:"
    docker --version
    log_info "[docker] Installation complete!"
else
    log_error "[docker] Installation failed"
    exit 1
fi
