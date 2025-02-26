#!/usr/bin/env bash
set -euo pipefail

log_info() {
  echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_warn() {
  echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_error() {
  echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

backup_file() {
  local file="$1"
  if [ -e "$file" ] || [ -L "$file" ]; then
    mv "$file" "${file}.backup.$(date +%s)"
    log_info "Backed up $file"
  fi
}

symlink_file() {
  local source_file="$1"
  local target_file="$2"
  backup_file "$target_file"
  ln -sf "$source_file" "$target_file"
  log_info "Linked $source_file -> $target_file"
}