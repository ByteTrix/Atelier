#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Installing Notion..."
# Example using snap (if available)
snap install notion-snap || { log_warn "[apps] Notion installation failed via snap. Please install manually."; }
