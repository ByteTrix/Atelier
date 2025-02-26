#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[browsers] Installing Google Chrome..."
if ! command -v google-chrome &>/dev/null; then
  wget -qO /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  apt install -y /tmp/google-chrome.deb
  rm /tmp/google-chrome.deb
  log_info "[browsers] Google Chrome installed."
else
  log_warn "[browsers] Google Chrome is already installed."
fi
