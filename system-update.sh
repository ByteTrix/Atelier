#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

log_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
log_info "System update complete."
