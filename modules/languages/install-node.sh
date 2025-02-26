#!/usr/bin/env bash
set -euo pipefail
# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source the shared utilities file from the repository root.
source "$DIR/../../lib/utils.sh"

log_info "[languages] Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
log_info "[languages] Node.js installation complete."
