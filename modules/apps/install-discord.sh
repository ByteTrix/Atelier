#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps] Installing Discord..."
snap install discord
log_info "[apps] Discord installed."