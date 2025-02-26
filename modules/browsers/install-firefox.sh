#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[browsers] Installing Firefox..."
apt install -y firefox
log_info "[browsers] Firefox installed."
