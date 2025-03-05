#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cli] Installing fd-find..."
sudo apt install -y fd-find
if [ ! -L /usr/local/bin/fd ]; then
  ln -s "$(which fdfind)" /usr/local/bin/fd
  log_info "[cli] Created symlink for fd."
fi
