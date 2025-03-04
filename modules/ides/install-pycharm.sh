#!/usr/bin/env bash
#
# PyCharm Installation
# ------------------
# Installs PyCharm Community Edition
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[pycharm] Installing PyCharm Community Edition..."

# Check if PyCharm is already installed
if ! command -v pycharm &> /dev/null; then
    # Add JetBrains repository
    log_info "[pycharm] Adding JetBrains repository..."
    curl -fsSL https://packages.jetbrains.team/maven/p/prj/products/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/jetbrains-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/jetbrains-keyring.gpg] https://packages.jetbrains.team/debian stable main" | sudo tee /etc/apt/sources.list.d/jetbrains.list

    # Update package lists
    sudo apt-get update

    # Install PyCharm Community Edition
    log_info "[pycharm] Installing PyCharm Community Edition..."
    sudo apt-get install -y pycharm-community

    # Create desktop entry if needed
    if [ ! -f "/usr/share/applications/pycharm.desktop" ]; then
        log_info "[pycharm] Creating desktop entry..."
        echo "[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=/opt/pycharm-community/bin/pycharm.png
Exec=/opt/pycharm-community/bin/pycharm.sh
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce" | sudo tee /usr/share/applications/pycharm.desktop
    fi

    log_success "[pycharm] PyCharm Community Edition installed successfully!"
    
    # Display help information
    log_info "[pycharm] Quick start guide:"
    echo "
    - Launch PyCharm: pycharm-community
    - First run will require initial setup and configuration
    - Import settings from previous installation if available
    - Configure Python interpreter for your projects
    "
else
    log_warn "[pycharm] PyCharm appears to be already installed."
fi