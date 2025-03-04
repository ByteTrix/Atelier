#!/usr/bin/env bash
#
# Eclipse IDE Installation
# ----------------------
# Installs Eclipse IDE for Java Developers
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[eclipse] Installing Eclipse IDE..."

# Installation directory
ECLIPSE_DIR="/opt/eclipse"
ECLIPSE_VERSION="2024-03" # Update this as needed

# Check if Eclipse is already installed
if [ ! -d "$ECLIPSE_DIR" ]; then
    # Install Java if not present
    if ! command -v java &> /dev/null; then
        log_info "[eclipse] Installing Java..."
        sudo apt-get update
        sudo apt-get install -y default-jdk
    fi

    # Create installation directory
    log_info "[eclipse] Creating installation directory..."
    sudo mkdir -p "$ECLIPSE_DIR"

    # Download Eclipse
    log_info "[eclipse] Downloading Eclipse IDE..."
    TEMP_DIR=$(mktemp -d)
    wget -O "$TEMP_DIR/eclipse.tar.gz" "https://mirror.csclub.uwaterloo.ca/eclipse/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/eclipse-java-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz"

    # Extract Eclipse
    log_info "[eclipse] Extracting Eclipse..."
    sudo tar xf "$TEMP_DIR/eclipse.tar.gz" -C "$ECLIPSE_DIR" --strip-components=1

    # Clean up temporary files
    rm -rf "$TEMP_DIR"

    # Set permissions
    sudo chown -R root:root "$ECLIPSE_DIR"
    sudo chmod -R +r "$ECLIPSE_DIR"

    # Create desktop entry
    log_info "[eclipse] Creating desktop entry..."
    echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Eclipse IDE
Icon=$ECLIPSE_DIR/icon.xpm
Exec=$ECLIPSE_DIR/eclipse
Comment=Eclipse IDE for Java Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=Eclipse" | sudo tee /usr/share/applications/eclipse.desktop

    # Create symbolic link
    sudo ln -sf "$ECLIPSE_DIR/eclipse" /usr/local/bin/eclipse

    log_success "[eclipse] Eclipse IDE installed successfully!"
    
    # Display help information
    log_info "[eclipse] Quick start guide:"
    echo "
    - Launch Eclipse: eclipse
    - First run will require workspace selection
    - Install additional plugins through Help -> Eclipse Marketplace
    - Configure Java Development Kit in Window -> Preferences -> Java -> Installed JREs
    "
else
    log_warn "[eclipse] Eclipse appears to be already installed in $ECLIPSE_DIR"
fi

# Verify installation
if command -v eclipse &> /dev/null; then
    log_info "[eclipse] Eclipse installation verified."
    eclipse -version
else
    log_error "[eclipse] Eclipse installation could not be verified."
fi