#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Notion is already installed
if snap list notion-snap &>/dev/null; then
    log_warn "[apps] Notion is already installed"
    snap list notion-snap
    return 0
fi

log_info "[apps] Installing Notion..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[apps] Snap is not installed. Please install snapd first."
    return 1
fi

# Try installing through snap
if snap install notion-snap; then
    if snap list notion-snap &>/dev/null; then
        log_success "[apps] Notion installed successfully via snap"
        snap list notion-snap
        return 0
    fi
fi

# Fallback to alternative installation method (Electron app)
log_warn "[apps] Snap installation failed, attempting alternative installation..."

# Create temp directory for download
TEMP_DIR=$(mktemp -d)
NOTION_DEB="$TEMP_DIR/notion.deb"

# Download latest Notion
if wget -O "$NOTION_DEB" "https://notion.davidbailey.codes/notion-desktop.deb"; then
    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y gconf2 gconf-service libappindicator1

    # Install Notion
    if sudo dpkg -i "$NOTION_DEB"; then
        log_success "[apps] Notion installed successfully via deb package"
        rm -rf "$TEMP_DIR"
        return 0
    else
        log_error "[apps] Failed to install Notion deb package"
        rm -rf "$TEMP_DIR"
        return 1
    fi
else
    log_error "[apps] Failed to download Notion"
    rm -rf "$TEMP_DIR"
    return 1
fi
