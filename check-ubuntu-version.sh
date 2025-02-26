#!/usr/bin/env bash
set -euo pipefail
source ./lib/utils.sh

log_info "Checking Ubuntu version..."
REQUIRED_VERSION="24.04"
current_version=$(lsb_release -rs)

if [[ "$current_version" < "$REQUIRED_VERSION" ]]; then
  log_error "Ubuntu $REQUIRED_VERSION or higher is required. Current version: $current_version."
  exit 1
fi

log_info "Ubuntu version $current_version is supported."
