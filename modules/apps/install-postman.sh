#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps] Installing Postman..."
snap install postman
log_info "[apps] Postman installed."