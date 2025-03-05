#!/usr/bin/env bash
set -euo pipefail

# ASCII art for Setupr logo
ascii_art='

███████╗███████╗████████╗██╗   ██╗██████╗ ██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ ██╔══██╗
███████║███████╗   ██║   ╚██████╔╝██║     ██║  ██║
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝  ╚═╝

'

# Check for proper sudo usage
if [ "$EUID" -eq 0 ] && [ -z "${SUDO_USER:-}" ]; then
    echo "Error: Please run with sudo, not as root directly"
    exit 1
elif [ "$EUID" -ne 0 ]; then
    echo "Error: Please run with sudo"
    exit 1
fi

# Set up installation directory
INSTALL_DIR="/usr/local/share/Setupr"
USER_HOME=$(eval echo ~${SUDO_USER})

echo -e "$ascii_art"
echo "=> Setupr is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

# Clone or update repository
if [ ! -d "$INSTALL_DIR/.git" ]; then
    mkdir -p "$INSTALL_DIR"
    echo "Cloning Setupr..."
    git clone https://github.com/ByteTrix/Setupr.git "$INSTALL_DIR" || {
        echo "Error: Failed to clone repository"
        exit 1
    }
    # Checkout the default branch
    cd "$INSTALL_DIR"
    git checkout "${Setupr_REF:-main}" || {
        echo "Error: Failed to switch to branch ${Setupr_REF:-main}"
        exit 1
    }
    cd - >/dev/null
else
    echo "Updating Setupr..."
    cd "$INSTALL_DIR"
    # Fetch and reset to the latest version
    git fetch origin "${Setupr_REF:-main}" || {
        echo "Error: Failed to fetch latest changes"
        exit 1
    }
    git reset --hard "origin/${Setupr_REF:-main}" || {
        echo "Error: Failed to update repository"
        exit 1
    }
    cd - >/dev/null
fi

# Make scripts executable and set permissions
chmod +x "$INSTALL_DIR"/{install,check-version,system-update}.sh
chmod +x "$INSTALL_DIR"/modules/*/*.sh 2>/dev/null || true
chown -R ${SUDO_USER}:${SUDO_USER} "$INSTALL_DIR"

# Ensure proper permissions for user configs
mkdir -p "${USER_HOME}/Downloads"
chown -R ${SUDO_USER}:${SUDO_USER} "${USER_HOME}/Downloads"

# Source utility functions
source "${INSTALL_DIR}/lib/utils.sh"

# Run system update
log_info "Running system update before installation..."
"$INSTALL_DIR/system-update.sh"

log_info "Starting Setupr installation..."

# Run install.sh with preserved environment variables
HOME="$USER_HOME" \
USER="$SUDO_USER" \
LOGNAME="$SUDO_USER" \
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin" \
sudo -E -H -u "$SUDO_USER" bash "$INSTALL_DIR/install.sh"
