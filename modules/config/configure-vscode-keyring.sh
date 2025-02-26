#!/usr/bin/env bash
set -euo pipefail
source ../../lib/utils.sh

USER_NAME=$(logname)
HOME_DIR="/home/${USER_NAME}"
VSCODE_ARGV="$HOME_DIR/.config/Code/User/argv.json"

log_info "[config] Configuring VS Code to use 'gnome-libsecret' for password storage..."
if [ -f "$VSCODE_ARGV" ]; then
  jq '. + {"password-store": "gnome-libsecret"}' "$VSCODE_ARGV" > "$VSCODE_ARGV.tmp" && mv "$VSCODE_ARGV.tmp" "$VSCODE_ARGV"
else
  mkdir -p "$(dirname "$VSCODE_ARGV")"
  echo '{ "password-store": "gnome-libsecret" }' > "$VSCODE_ARGV"
fi
log_info "[config] VS Code configuration updated."
