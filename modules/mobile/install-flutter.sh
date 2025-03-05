#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[mobile] Installing Flutter SDK..."
snap install flutter --classic
log_info "[mobile] Flutter SDK installed."
