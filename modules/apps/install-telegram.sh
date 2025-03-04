#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps] Installing Telegram..."
snap install telegram-desktop
log_info "[apps] Telegram installed."
