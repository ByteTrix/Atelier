#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[cli] Installing ripgrep..."
sudo apt install -y ripgrep
log_info "[cli] ripgrep installed."
