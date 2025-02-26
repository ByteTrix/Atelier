#!/usr/bin/env bash
set -euo pipefail
# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source the shared utilities file from the repository root.
source "$DIR/../../lib/utils.sh"

log_info "[languages] Installing Python 3 and related tools..."
sudo apt install -y python3 python3-pip python3-venv
log_info "[languages] Python installation complete."
