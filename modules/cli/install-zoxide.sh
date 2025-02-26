#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing zoxide..."
apt install -y zoxide
log_info "[cli] zoxide installed."
