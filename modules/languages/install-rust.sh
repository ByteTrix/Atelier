#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

if ! command -v rustup &>/dev/null; then
  log_info "[languages] Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "/home/$(logname)/.cargo/env"
else
  log_info "[languages] Rust already installed."
fi
