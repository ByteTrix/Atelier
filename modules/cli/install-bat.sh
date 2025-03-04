#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[cli] Installing bat..."
sudo apt install -y bat
log_info "[cli] bat installed."
