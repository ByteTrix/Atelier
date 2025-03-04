#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Installing Xournal++..."
apt install -y xournalpp
log_info "[apps] Xournal++ installed."
