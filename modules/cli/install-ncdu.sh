#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing ncdu..."
sudo apt install -y ncdu
log_info "[cli] ncdu installed."
