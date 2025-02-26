#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing tig..."
sudo apt install -y tig
log_info "[cli] tig installed."
