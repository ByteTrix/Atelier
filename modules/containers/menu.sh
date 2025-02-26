#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
source "$DIR/../../lib/utils.sh"

log_info "[containers/menu] Launching container tools installation menu using Gum..."

declare -A options=(
  ["Docker"]="install-docker.sh"
  ["Docker Compose"]="install-docker-compose.sh"
  ["kubectl"]="install-kubectl.sh"
)

descriptions=("${!options[@]}")

selected=$(gum choose --no-limit --header "Container Tools" \
  --header "Select container tools to install:" "${descriptions[@]}")

if [ -z "$selected" ]; then
  log_warn "[containers/menu] No container tools selected; skipping."
  exit 0
fi

while IFS= read -r desc; do
  script="${options[$desc]}"
  log_info "[containers/menu] Selected: $desc -> $script"
  echo "$DIR/$script"
done <<< "$selected"
log_info "[containers/menu] Container tools installation complete."
