#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[cli] Installing fd-find..."
sudo apt install -y fd-find
if [ ! -L /usr/local/bin/fd ]; then
  ln -s "$(which fdfind)" /usr/local/bin/fd
  log_info "[cli] Created symlink for fd."
fi
