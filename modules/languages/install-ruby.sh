#!/usr/bin/env bash
set -euo pipefail
# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source the shared utilities file from the repository root.
source "$DIR/../../lib/utils.sh"

log_info "[languages] Installing Ruby and Bundler..."
sudo apt install -y ruby-full
gem install bundler
log_info "[languages] Ruby installation complete."
