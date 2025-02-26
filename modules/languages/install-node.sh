#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/modules/lib/utils.sh

log_info "[languages] Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
log_info "[languages] Node.js installation complete."
