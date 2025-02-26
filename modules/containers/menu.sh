#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

log_info "[containers/menu] Launching container tools menu using Gum..."

options=(
  "install-docker.sh"         "Docker"
  "install-docker-compose.sh" "Docker Compose"
  "install-kubectl.sh"        "kubectl"
)

selected=$(gum checkbox --title "Container Tools" \
  --header "Select container tools to install:" \
  --separator "\n" \
  "${options[@]}")

if [ -z "$selected" ]; then
  log_warn "[containers/menu] No container tools selected; skipping."
  exit 0
fi

while IFS= read -r script; do
  log_info "[containers/menu] Executing $script..."
  bash "$script"
done <<< "$selected"

log_info "[containers/menu] Container tools installation complete."
