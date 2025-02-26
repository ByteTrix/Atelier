#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[mobile] Installing Flutter SDK..."
snap install flutter --classic
log_info "[mobile] Flutter SDK installed."
