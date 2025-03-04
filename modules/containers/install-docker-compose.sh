#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[containers] Installing Docker Compose..."
apt install -y docker-compose
log_info "[containers] Docker Compose installed."
