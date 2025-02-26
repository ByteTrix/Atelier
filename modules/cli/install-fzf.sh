#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli] Installing fzf..."
apt install -y fzf
log_info "[cli] fzf installed."
