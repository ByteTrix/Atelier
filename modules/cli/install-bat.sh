#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[cli] Installing bat..."
apt install -y bat
log_info "[cli] bat installed."
