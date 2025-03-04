#!/usr/bin/env bash
#
# Container Tools Installation Menu
# -------------------------------
# Interactive menu for installing container management tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[containers] Initializing container tools installation menu..."

# Define available container tool options with descriptions
declare -A CONTAINER_OPTIONS=(
  ["Docker (Container runtime & builder)"]="install-docker.sh"
  ["Docker Compose (Multi-container orchestration)"]="install-docker-compose.sh"
  ["kubectl (Kubernetes CLI tool)"]="install-kubectl.sh"
  ["Podman (Daemonless container engine)"]="install-podman.sh"
  ["Minikube (Local Kubernetes)"]="install-minikube.sh"
  ["Helm (Kubernetes package manager)"]="install-helm.sh"
)

CONTAINER_DESCRIPTIONS=("${!CONTAINER_OPTIONS[@]}")

# Display interactive selection menu
log_info "[containers] Displaying container tools selection menu..."
SELECTED_TOOLS=$(gum choose \
  --no-limit \
  --height 15 \
  --header "🐳 Container Tools Installation" \
  --header.foreground="99" \
  --header "Select container tools to install (space to select, enter to confirm):" \
  "${CONTAINER_DESCRIPTIONS[@]}")

# Handle empty selection
if [ -z "$SELECTED_TOOLS" ]; then
  log_warn "[containers] No container tools selected; skipping installation."
  exit 0
fi

# Process selected options
log_info "[containers] Processing selected container tool installations..."
while IFS= read -r SELECTION; do
  SCRIPT="${CONTAINER_OPTIONS[$SELECTION]}"
  log_info "[containers] Queuing: $SELECTION"
  echo "${SCRIPT_DIR}/${SCRIPT}"
done <<< "$SELECTED_TOOLS"

log_info "[containers] Container tools selection complete."
