#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli] Installing exa..."
apt install -y exa
log_info "[cli] exa installed."
