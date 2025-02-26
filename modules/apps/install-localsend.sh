#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Installing Localsend..."
# Assuming Localsend is available as a deb or via snap; here using snap:
snap install localsend || { log_warn "[apps] Localsend installation failed; please install manually."; }
