#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Installing VLC Media Player..."
apt install -y vlc
log_info "[apps] VLC installed."
