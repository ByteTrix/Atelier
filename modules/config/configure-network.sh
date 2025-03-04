#!/usr/bin/env bash
#
# Network Configuration
# -------------------
# Configure network interfaces and settings
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[network] Starting network configuration..."

# Check for NetworkManager
if ! command -v nmcli &> /dev/null; then
    log_info "[network] Installing NetworkManager..."
    sudo apt-get update
    sudo apt-get install -y network-manager
fi

# Function to list available WiFi networks
list_wifi_networks() {
    log_info "[network] Scanning for WiFi networks..."
    nmcli device wifi list
}

# Function to list all network interfaces
list_interfaces() {
    log_info "[network] Available network interfaces:"
    nmcli device status
}

# Function to configure WiFi
configure_wifi() {
    # List available WiFi networks
    list_wifi_networks
    
    # Get SSID
    log_info "[network] Enter WiFi details:"
    SSID=$(gum input --placeholder "Enter WiFi SSID")
    
    if [ -z "$SSID" ]; then
        log_warn "[network] No SSID provided; skipping WiFi configuration."
        return
    fi
    
    # Get password (hidden input)
    PASSWORD=$(gum input --password --placeholder "Enter WiFi password")
    
    if [ -z "$PASSWORD" ]; then
        log_warn "[network] No password provided; skipping WiFi configuration."
        return
    fi
    
    # Connect to WiFi
    log_info "[network] Connecting to WiFi network: $SSID"
    if nmcli device wifi connect "$SSID" password "$PASSWORD"; then
        log_success "[network] Successfully connected to $SSID"
    else
        log_error "[network] Failed to connect to $SSID"
    fi
}

# Function to configure ethernet
configure_ethernet() {
    # List ethernet interfaces
    ETHERNET_DEVICES=$(nmcli device status | grep ethernet | awk '{print $1}')
    
    if [ -z "$ETHERNET_DEVICES" ]; then
        log_warn "[network] No ethernet devices found."
        return
    fi
    
    for DEVICE in $ETHERNET_DEVICES; do
        log_info "[network] Configuring ethernet device: $DEVICE"
        
        # Choose between DHCP and static IP
        IP_MODE=$(gum choose "DHCP" "Static IP" \
            --header="Select IP configuration mode for $DEVICE:" \
            --header.foreground="99")
        
        if [ "$IP_MODE" = "DHCP" ]; then
            log_info "[network] Configuring $DEVICE with DHCP..."
            sudo nmcli device modify "$DEVICE" ipv4.method auto
            
        elif [ "$IP_MODE" = "Static IP" ]; then
            # Get static IP configuration
            IP_ADDRESS=$(gum input --placeholder "Enter IP address (e.g., 192.168.1.100/24)")
            GATEWAY=$(gum input --placeholder "Enter gateway IP (e.g., 192.168.1.1)")
            DNS=$(gum input --placeholder "Enter DNS servers (comma-separated, e.g., 8.8.8.8,8.8.4.4)")
            
            if [ -n "$IP_ADDRESS" ] && [ -n "$GATEWAY" ] && [ -n "$DNS" ]; then
                log_info "[network] Configuring $DEVICE with static IP..."
                sudo nmcli device modify "$DEVICE" \
                    ipv4.method manual \
                    ipv4.addresses "$IP_ADDRESS" \
                    ipv4.gateway "$GATEWAY" \
                    ipv4.dns "$DNS"
            else
                log_warn "[network] Incomplete static IP configuration; skipping."
            fi
        fi
    done
}

# Main menu
while true; do
    ACTION=$(gum choose \
        "List Network Interfaces" \
        "Configure WiFi" \
        "Configure Ethernet" \
        "Exit" \
        --header="🌐 Network Configuration Menu" \
        --header.foreground="99")
    
    case "$ACTION" in
        "List Network Interfaces")
            list_interfaces
            ;;
        "Configure WiFi")
            configure_wifi
            ;;
        "Configure Ethernet")
            configure_ethernet
            ;;
        "Exit")
            break
            ;;
    esac
done

log_success "[network] Network configuration complete!"