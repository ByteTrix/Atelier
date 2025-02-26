#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[containers] Installing Docker..."
apt install -y docker.io
systemctl enable --now docker
log_info "[containers] Docker installed."
