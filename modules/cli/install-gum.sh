#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

if ! command -v gum &>/dev/null; then
  log_info "[cli] Installing Gum..."
  apt update && apt install -y wget gnupg2 && \
  wget -qO- https://raw.githubusercontent.com/charmbracelet/gum/main/install.sh | bash
else
  log_info "[cli] Gum is already installed."
fi
