#!/usr/bin/env bash
#
# PyCharm Installation
# ------------------
# Installs PyCharm Community Edition
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if PyCharm is already installed
if command -v pycharm-community &>/dev/null; then
    log_warn "[pycharm] PyCharm is already installed"
    pycharm-community --version 2>/dev/null || true
    return 0
fi

log_info "[pycharm] Installing PyCharm Community Edition..."

# Create keyrings directory
sudo_exec mkdir -p /usr/share/keyrings

# Add JetBrains repository
log_info "[pycharm] Adding JetBrains repository key..."
if ! curl -fsSL https://packages.jetbrains.team/maven/p/prj/products/keyring.gpg | sudo_exec gpg --dearmor -o /usr/share/keyrings/jetbrains-keyring.gpg; then
    log_error "[pycharm] Failed to add repository key"
    return 1
fi

# Add repository
log_info "[pycharm] Adding JetBrains repository..."
if ! echo "deb [signed-by=/usr/share/keyrings/jetbrains-keyring.gpg] https://packages.jetbrains.team/debian stable main" | sudo_exec tee /etc/apt/sources.list.d/jetbrains.list > /dev/null; then
    log_error "[pycharm] Failed to add repository"
    return 1
fi

# Update package lists
log_info "[pycharm] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[pycharm] Failed to update package lists"
    return 1
fi

# Install PyCharm Community Edition
log_info "[pycharm] Installing PyCharm Community Edition..."
if ! sudo_exec apt-get install -y pycharm-community; then
    log_error "[pycharm] Failed to install PyCharm"
    return 1
fi

# Create desktop entry if needed
if [ ! -f "/usr/share/applications/pycharm.desktop" ]; then
    log_info "[pycharm] Creating desktop entry..."
    if ! echo "[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=/opt/pycharm-community/bin/pycharm.png
Exec=/opt/pycharm-community/bin/pycharm.sh
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce" | sudo_exec tee /usr/share/applications/pycharm.desktop > /dev/null; then
        log_warn "[pycharm] Failed to create desktop entry"
    fi
fi

# Verify installation
if command -v pycharm-community &>/dev/null; then
    log_success "[pycharm] PyCharm Community Edition installed successfully"
    pycharm-community --version 2>/dev/null || true
    
    # Display help information
    log_info "[pycharm] Quick start guide:"
    echo "
    - Launch PyCharm: pycharm-community
    - First run will require initial setup and configuration
    - Import settings from previous installation if available
    - Configure Python interpreter for your projects
    "
    return 0
else
    log_error "[pycharm] PyCharm installation could not be verified"
    return 1
fi