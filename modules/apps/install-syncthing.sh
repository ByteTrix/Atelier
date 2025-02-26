#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Syncthing..."
snap install syncthing
log_info "[apps] Syncthing installed."
