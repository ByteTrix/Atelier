#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[apps] Installing Spotify..."
snap install spotify
log_info "[apps] Spotify installed."
