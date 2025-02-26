#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[mobile] Installing Android Studio..."
if ! command -v studio.sh &>/dev/null; then
  add-apt-repository -y ppa:maarten-fonville/android-studio
  apt update && apt install -y android-studio
  log_info "[mobile] Android Studio installed."
else
  log_warn "[mobile] Android Studio already installed."
fi
