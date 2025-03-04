#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps] Installing Todoist..."
snap install todoist || { log_warn "[apps] Todoist installation failed; please install manually."; }
