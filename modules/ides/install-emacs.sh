#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ides] Installing GNU Emacs..."
apt install -y emacs
log_info "[ides] GNU Emacs installed."
