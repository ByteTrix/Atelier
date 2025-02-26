#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing bat..."
sudo apt install -y bat
log_info "[cli] bat installed."
