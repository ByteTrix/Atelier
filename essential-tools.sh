#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

log_info "Installing essential tools..."

# Install basic development tools
sudo apt install -y \
  build-essential \
  curl \
  wget \
  git \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

log_info "Essential tools installation complete."
