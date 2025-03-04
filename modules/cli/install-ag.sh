#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[cli] Installing The Silver Searcher (ag)..."
sudo apt install -y silversearcher-ag
log_info "[cli] ag installed."
