#!/usr/bin/env bash
#
# UFW Firewall Configuration
# ------------------------
# Configures and enables UFW firewall with basic rules
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[firewall] Configuring UFW firewall..."

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    log_info "[firewall] Installing UFW..."
    sudo apt-get update
    sudo apt-get install -y ufw
fi

# Reset UFW to default configuration
log_info "[firewall] Resetting UFW to default configuration..."
sudo ufw reset

# Set default policies
log_info "[firewall] Setting default policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (port 22) to prevent lockout
log_info "[firewall] Allowing SSH connections..."
sudo ufw allow ssh

# Allow common web ports
log_info "[firewall] Configuring common web ports..."
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS

# Enable UFW if not already enabled
if ! sudo ufw status | grep -q "Status: active"; then
    log_info "[firewall] Enabling UFW..."
    # Enable UFW without prompt
    echo "y" | sudo ufw enable
    
    log_success "[firewall] UFW has been enabled and configured!"
else
    log_warn "[firewall] UFW is already enabled."
fi

# Show current UFW status
log_info "[firewall] Current UFW status:"
sudo ufw status verbose