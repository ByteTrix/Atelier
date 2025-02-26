#!/usr/bin/env bash
set -euo pipefail

log_info "[cli/install-gum] Checking for curl..."
if ! command -v curl &>/dev/null; then
  log_info "[cli/install-gum] curl is not installed. Installing curl..."
  apt update && apt install -y curl
fi

cd /tmp
GUM_VERSION="0.14.3"  # Use a known good version
log_info "[cli/install-gum] Downloading Gum version ${GUM_VERSION}..."
curl -fsSL -o gum.deb "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"

log_info "[cli/install-gum] Installing Gum..."
sudo dpkg -i gum.deb || sudo apt-get -f install -y

rm -f gum.deb
cd -
log_info "[cli/install-gum] Gum installation complete."
