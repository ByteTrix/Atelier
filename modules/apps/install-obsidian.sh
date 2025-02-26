#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[apps] Installing Obsidian..."
snap install obsidian
log_info "[apps] Obsidian installed."
