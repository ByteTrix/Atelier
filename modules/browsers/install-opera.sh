#!/usr/bin/env bash
#
# Opera Browser Installation
# ------------------------
# Installs Opera web browser using official repository
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[opera] Installing Opera browser..."

# Add Opera repository key
if ! command -v opera &> /dev/null; then
    log_info "[opera] Adding Opera repository..."
    wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
    echo "deb https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera.list

    # Update package lists
    log_info "[opera] Updating package lists..."
    sudo apt-get update

    # Install Opera
    log_info "[opera] Installing Opera browser..."
    sudo apt-get install -y opera-stable

    log_success "[opera] Opera browser installed successfully!"
else
    log_warn "[opera] Opera browser is already installed."
fi