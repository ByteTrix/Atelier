#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing exa..."
sudo apt install -y exa
log_info "[cli] exa installed."
