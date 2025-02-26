#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

log_info "[languages] Installing Ruby and Bundler..."
apt install -y ruby-full
gem install bundler
log_info "[languages] Ruby installation complete."
