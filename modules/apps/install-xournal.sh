#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Xournal++..."
apt install -y xournalpp
log_info "[apps] Xournal++ installed."
