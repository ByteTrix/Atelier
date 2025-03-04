#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Installing The Silver Searcher (ag)..."
sudo apt install -y silversearcher-ag
log_info "[cli] ag installed."
