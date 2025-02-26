#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[apps] Installing Syncthing..."
snap install syncthing
log_info "[apps] Syncthing installed."
