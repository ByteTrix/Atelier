#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "Updating system packages..."
apt update && apt upgrade -y
log_info "System update complete."
