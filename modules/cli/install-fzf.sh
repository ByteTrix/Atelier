#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing fzf..."
sudo apt install -y fzf
log_info "[cli] fzf installed."
