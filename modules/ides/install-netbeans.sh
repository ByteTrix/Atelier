#!/usr/bin/env bash
#
# NetBeans IDE Installation
# -----------------------
# Installs Apache NetBeans IDE
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if NetBeans is already installed
if command -v netbeans &>/dev/null; then
    log_warn "[netbeans] Apache NetBeans is already installed"
    netbeans --version
    return 0
fi

log_info "[netbeans] Installing Apache NetBeans IDE..."

# Install Java if not present
if ! command -v java &>/dev/null; then
    log_info "[netbeans] Installing Java..."
    if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y default-jdk; then
        log_error "[netbeans] Failed to install Java"
        return 1
    fi
fi

# Add Apache NetBeans repository
log_info "[netbeans] Adding Apache NetBeans repository..."
if ! sudo_exec add-apt-repository -y ppa:linuxuprising/apache-netbeans; then
    log_error "[netbeans] Failed to add NetBeans repository"
    return 1
fi

# Update package lists
log_info "[netbeans] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[netbeans] Failed to update package lists"
    return 1
fi

# Install NetBeans
log_info "[netbeans] Installing Apache NetBeans..."
if ! sudo_exec apt-get install -y apache-netbeans; then
    log_error "[netbeans] Failed to install NetBeans"
    return 1
fi

# Create desktop entry if not present
if [ ! -f "/usr/share/applications/netbeans.desktop" ]; then
    log_info "[netbeans] Creating desktop entry..."
    if ! echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Apache NetBeans IDE
Icon=/usr/share/apache-netbeans/nb/netbeans.png
Exec=netbeans
Comment=Apache NetBeans IDE for Java Development
Categories=Development;IDE;Java;
Terminal=false
StartupWMClass=Apache NetBeans IDE" | sudo_exec tee /usr/share/applications/netbeans.desktop > /dev/null; then
        log_warn "[netbeans] Failed to create desktop entry"
    fi
fi

# Verify installation
if command -v netbeans &>/dev/null; then
    log_success "[netbeans] Apache NetBeans IDE installed successfully"
    netbeans --version
    
    # Display help information
    log_info "[netbeans] Quick start guide:"
    echo "
    - Launch NetBeans: netbeans
    - First run will require initial setup
    - Configure Java Platform in Tools -> Java Platforms
    - Install plugins through Tools -> Plugins
    - Set up version control in Team -> Git
    "
    return 0
else
    log_error "[netbeans] NetBeans installation could not be verified"
    return 1
fi