#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ides] Installing Geany IDE..."
apt install -y geany
log_info "[ides] Geany installed."
