#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[ides] Installing GNU Emacs..."
apt install -y emacs
log_info "[ides] GNU Emacs installed."
