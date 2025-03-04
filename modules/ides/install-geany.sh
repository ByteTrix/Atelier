#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[ides] Installing Geany IDE..."
apt install -y geany
log_info "[ides] Geany installed."
