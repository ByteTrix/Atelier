#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[cli] Installing lsd..."
sudo apt install -y lsd
log_info "[cli] lsd installed."
