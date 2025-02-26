#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[apps] Setting up WhatsApp..."
# For WhatsApp, you can create a desktop shortcut for WhatsApp Web
# or use a snap package if available.
snap install whatsapp-for-linux || { log_warn "[apps] WhatsApp installation failed; please install manually."; }
