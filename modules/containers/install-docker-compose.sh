#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

DOCKER_COMPOSE_VERSION="v2.24.0"  # Pin to stable version

log_info "[containers] Installing Docker Compose ${DOCKER_COMPOSE_VERSION}..."
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
if docker-compose --version; then
    log_success "[containers] Docker Compose ${DOCKER_COMPOSE_VERSION} installed successfully"
else
    log_error "[containers] Docker Compose installation failed"
    exit 1
fi
