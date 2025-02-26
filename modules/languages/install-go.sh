#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/modules/lib/utils.sh

log_info "[languages] Installing Golang..."
apt install -y golang
log_info "[languages] Golang installation complete."
