#!/usr/bin/env bash
#
# Module Template
# --------------
# Template for module installation scripts with proper sudo handling
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Determine sudo command based on environment
if [[ "${SETUPR_SUDO:-0}" == "1" ]]; then
    SUDO_CMD="sudo_exec"
else
    SUDO_CMD="sudo"
fi

# Installation logic here, using $SUDO_CMD instead of sudo
# Example:
# $SUDO_CMD apt-get update
# $SUDO_CMD apt-get install -y package-name

log_info "[module] Installation complete."