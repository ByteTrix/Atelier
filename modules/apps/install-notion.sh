#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[apps] Installing Notion..."
# Example using snap (if available)
snap install notion-snap || { log_warn "[apps] Notion installation failed via snap. Please install manually."; }
