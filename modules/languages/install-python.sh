#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/modules/lib/utils.sh

log_info "[languages] Installing Python 3 and related tools..."
apt install -y python3 python3-pip python3-venv
log_info "[languages] Python installation complete."
