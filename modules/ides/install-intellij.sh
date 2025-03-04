#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ides] Installing IntelliJ IDEA Community Edition via Snap..."
if ! snap list | grep -q intellij-idea-community; then
  snap install intellij-idea-community --classic
  log_info "[ides] IntelliJ IDEA installed."
else
  log_warn "[ides] IntelliJ IDEA is already installed."
fi
