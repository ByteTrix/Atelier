#!/usr/bin/env bash
#
# Eclipse IDE Installation
# ----------------------
# Installs Eclipse IDE for Java Developers
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Disable exit on error to prevent stopping the entire installation
set +e

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
    if ! sudo mkdir -p "$ECLIPSE_DIR"; then
        log_error "[eclipse] Failed to create installation directory"
        return 1
    fi
    
    # Download Eclipse
    log_info "[eclipse] Downloading Eclipse IDE..."
    TEMP_DIR=$(mktemp -d)
    if ! wget -O "$TEMP_DIR/eclipse.tar.gz" "https://mirror.csclub.uwaterloo.ca/eclipse/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/eclipse-java-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz"; then
        log_error "[eclipse] Failed to download Eclipse"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Extract Eclipse
    log_info "[eclipse] Extracting Eclipse..."
    if ! sudo tar xf "$TEMP_DIR/eclipse.tar.gz" -C "$ECLIPSE_DIR" --strip-components=1; then
        log_error "[eclipse] Failed to extract Eclipse"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up temporary files
    rm -rf "$TEMP_DIR"
    
    # Set permissions
    if ! sudo chown -R root:root "$ECLIPSE_DIR"; then
        log_error "[eclipse] Failed to set ownership"
        return 1
    fi
    
    if ! sudo chmod -R +r "$ECLIPSE_DIR"; then
        log_error "[eclipse] Failed to set permissions"
        return 1
    fi
    
    # Create desktop entry
    log_info "[eclipse] Creating desktop entry..."
    if ! echo "[Desktop Entry]
    Version=1.0
    Type=Application
    Name=Eclipse IDE
    Icon=$ECLIPSE_DIR/icon.xpm
    Exec=$ECLIPSE_DIR/eclipse
    Comment=Eclipse IDE for Java Developers
    Categories=Development;IDE;
    Terminal=false
    StartupWMClass=Eclipse" | sudo tee /usr/share/applications/eclipse.desktop > /dev/null; then
        log_error "[eclipse] Failed to create desktop entry"
        return 1
    fi
    
    # Create symbolic link
    if ! sudo ln -sf "$ECLIPSE_DIR/eclipse" /usr/local/bin/eclipse; then
        log_error "[eclipse] Failed to create symbolic link"
        return 1
    fi
    
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
    if eclipse -version &>/dev/null; then
        log_success "[eclipse] Eclipse version check passed"
        return 0
    else
        log_error "[eclipse] Eclipse version check failed"
        return 1
    fi
else
    log_error "[eclipse] Eclipse installation could not be verified."
    return 1
fi