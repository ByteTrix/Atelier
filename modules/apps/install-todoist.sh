#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Installing Todoist..."
snap install todoist || { log_warn "[apps] Todoist installation failed; please install manually."; }
