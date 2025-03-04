#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps] Installing VLC Media Player..."
apt install -y vlc
log_info "[apps] VLC installed."
