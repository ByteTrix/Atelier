#!/usr/bin/env bash
set -euo pipefail
# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source the shared utilities file from the repository root.
source "$DIR/../../lib/utils.sh"

log_info "[languages] Installing Golang..."
apt install -y golang
log_info "[languages] Golang installation complete."
