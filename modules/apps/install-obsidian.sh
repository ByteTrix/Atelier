#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Obsidian..."
snap install obsidian
log_info "[apps] Obsidian installed."
