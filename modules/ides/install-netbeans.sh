#!/usr/bin/env bash
#
# NetBeans IDE Installation
# -----------------------
# Installs Apache NetBeans IDE
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[netbeans] Installing Apache NetBeans IDE..."

# Check if NetBeans is already installed
if ! command -v netbeans &> /dev/null; then
    # Install Java if not present
    if ! command -v java &> /dev/null; then
        log_info "[netbeans] Installing Java..."
        sudo apt-get update
        sudo apt-get install -y default-jdk
    fi

    # Add Apache NetBeans repository
    log_info "[netbeans] Adding Apache NetBeans repository..."
    sudo add-apt-repository -y ppa:linuxuprising/apache-netbeans
    
    # Update package lists
    sudo apt-get update
    
    # Install NetBeans
    log_info "[netbeans] Installing Apache NetBeans..."
    sudo apt-get install -y apache-netbeans
    
    # Create desktop entry if not present
    if [ ! -f "/usr/share/applications/netbeans.desktop" ]; then
        log_info "[netbeans] Creating desktop entry..."
        echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Apache NetBeans IDE
Icon=/usr/share/apache-netbeans/nb/netbeans.png
Exec=netbeans
Comment=Apache NetBeans IDE for Java Development
Categories=Development;IDE;Java;
Terminal=false
StartupWMClass=Apache NetBeans IDE" | sudo tee /usr/share/applications/netbeans.desktop
    fi

    log_success "[netbeans] Apache NetBeans IDE installed successfully!"
    
    # Display help information
    log_info "[netbeans] Quick start guide:"
    echo "
    - Launch NetBeans: netbeans
    - First run will require initial setup
    - Configure Java Platform in Tools -> Java Platforms
    - Install plugins through Tools -> Plugins
    - Set up version control in Team -> Git
    "
else
    log_warn "[netbeans] Apache NetBeans appears to be already installed."
fi

# Verify installation
if command -v netbeans &> /dev/null; then
    log_info "[netbeans] NetBeans installation verified."
    netbeans --version
else
    log_error "[netbeans] NetBeans installation could not be verified."
fi