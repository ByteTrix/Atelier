#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Ulauncher..."
snap install ulauncher --classic
log_info "[apps] Ulauncher installed."
