#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Dropbox..."
apt install -y dropbox
log_info "[apps] Dropbox installed."
