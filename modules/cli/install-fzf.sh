#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Installing fzf..."
sudo apt install -y fzf
log_info "[cli] fzf installed."
