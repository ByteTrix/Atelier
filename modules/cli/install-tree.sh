#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli] Installing tree..."
apt install -y tree
log_info "[cli] tree installed."
