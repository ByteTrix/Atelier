#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing tree..."
sudo apt install -y tree
log_info "[cli] tree installed."
