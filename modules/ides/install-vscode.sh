#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[ides] Installing Visual Studio Code..."
if ! command -v code &>/dev/null; then
  wget -qO /tmp/code.deb https://go.microsoft.com/fwlink/?LinkID=760868
  apt install -y /tmp/code.deb
  rm /tmp/code.deb
  log_info "[ides] Visual Studio Code installed."
else
  log_warn "[ides] Visual Studio Code is already installed."
fi
