#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/share/Setupr"
source "${INSTALL_DIR}/lib/utils.sh"

log_info "Running system cleanup..."

# Clean package cache
sudo apt clean
sudo apt autoremove -y

# Remove temporary files
sudo rm -rf /tmp/*

# Clean user cache
rm -rf ~/.cache/*

log_info "System cleanup complete."
