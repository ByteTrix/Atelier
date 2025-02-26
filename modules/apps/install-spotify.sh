#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Spotify..."
snap install spotify
log_info "[apps] Spotify installed."
