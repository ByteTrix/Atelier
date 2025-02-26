#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing lsd..."
apt install -y lsd
log_info "[cli] lsd installed."
