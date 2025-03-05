#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

if command -v jq &>/dev/null; then
    log_info "jq is already installed"
    exit 0
fi

log_info "Installing jq..."

# Install jq
sudo apt update
sudo apt install -y jq

log_info "Installed jq successfully"