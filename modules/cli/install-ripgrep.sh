#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Installing ripgrep..."
sudo apt install -y ripgrep
log_info "[cli] ripgrep installed."
