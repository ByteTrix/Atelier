#!/usr/bin/env bash
set -euo pipefail
source ./lib/utils.sh

log_info "Performing system cleanup..."
apt autoremove -y
apt autoclean
log_info "System cleanup complete."
