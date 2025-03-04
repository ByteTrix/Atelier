#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/../../lib/utils.sh"

if command -v jq &>/dev/null; then
    log_info "jq is already installed"
    exit 0
fi

log_info "Installing jq..."

# Install jq based on package manager
if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y jq
elif command -v dnf &>/dev/null; then
    sudo dnf install -y jq
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm jq
elif command -v zypper &>/dev/null; then
    sudo zypper install -y jq
else
    log_error "Unsupported package manager"
    exit 1
fi

log_info "Installed jq successfully"