#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "[browsers] Installing Brave Browser..."
if ! command -v brave-browser &>/dev/null; then
  sudo apt install -y apt-transport-https curl
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
  apt update
  apt install -y brave-browser
  log_info "[browsers] Brave Browser installed."
else
  log_warn "[browsers] Brave Browser is already installed."
fi
