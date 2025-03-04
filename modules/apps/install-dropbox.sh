#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps] Installing Dropbox..."
apt install -y dropbox
log_info "[apps] Dropbox installed."
