#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[apps] Installing Zoom..."
# Add Zoom repository and key
curl -fsSL https://zoom.us/linux/download/pubkey | sudo gpg --dearmor -o /usr/share/keyrings/zoom-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/zoom-keyring.gpg] https://zoom.us/linux/download/deb stable main" | sudo tee /etc/apt/sources.list.d/zoom.list

# Update package list and install Zoom
sudo apt update
sudo apt install -y zoom
log_info "[apps] Zoom installed."