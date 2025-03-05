#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[mobile] Installing Android Studio..."
if ! command -v studio.sh &>/dev/null; then
  add-apt-repository -y ppa:maarten-fonville/android-studio
  apt update && apt install -y android-studio
  log_info "[mobile] Android Studio installed."
else
  log_warn "[mobile] Android Studio already installed."
fi
