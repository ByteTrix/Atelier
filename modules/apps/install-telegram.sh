#!/usr/bin/env bash
#
# Telegram Installation
# ------------------
# Installs Telegram Desktop messaging application
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[telegram] Installing Telegram..."

# Check if Telegram is already installed
if ! command -v telegram-desktop &> /dev/null; then
    # Install dependencies and Telegram
    log_info "[telegram] Installing Telegram Desktop..."
    sudo apt-get update
    sudo apt-get install -y telegram-desktop

    log_success "[telegram] Telegram Desktop installed successfully!"
else
    log_warn "[telegram] Telegram Desktop is already installed"
fi

# Verify installation
if command -v telegram-desktop &> /dev/null; then
    log_info "[telegram] Version information:"
    telegram-desktop --version
else
    log_error "[telegram] Installation failed"
    exit 1
fi
