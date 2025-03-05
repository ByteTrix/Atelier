#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Installing zoxide..."
sudo apt install -y zoxide
log_info "[cli] zoxide installed."
