#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

log_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
log_info "System update complete."
