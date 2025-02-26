#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli] Installing The Silver Searcher (ag)..."
apt install -y silversearcher-ag
log_info "[cli] ag installed."
