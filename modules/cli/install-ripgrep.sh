#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli] Installing ripgrep..."
apt install -y ripgrep
log_info "[cli] ripgrep installed."
