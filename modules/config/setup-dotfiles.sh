#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

USER_NAME=$(logname)
HOME_DIR="/home/${USER_NAME}"
DOTFILES_DIR="$HOME_DIR/dotfiles"

log_info "[config] Setting up dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
  declare -a FILES=("zshrc" "vimrc" "nvim/init.vim" "gitconfig")
  for file in "${FILES[@]}"; do
    target="$HOME_DIR/.$(basename "$file")"
    source="$DOTFILES_DIR/$file"
    symlink_file "$source" "$target"
  done
  log_info "[config] Dotfiles setup complete."
else
  log_warn "[config] Dotfiles directory not found at $DOTFILES_DIR; skipping."
fi
