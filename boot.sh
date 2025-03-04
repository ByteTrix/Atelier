#!/usr/bin/env bash
set -e

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

echo -e "$ascii_art"
echo "=> Setupr is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

# Install git if not present
# Set up installation directory
INSTALL_DIR="/usr/local/share/Setupr"

# Only clone if directory doesn't exist or is empty
if [ ! -d "$INSTALL_DIR/.git" ]; then
    mkdir -p "$INSTALL_DIR"
    echo "Cloning Setupr..."
    git clone -b upgrage https://github.com/ByteTrix/Setupr.git "$INSTALL_DIR"
else
    echo "Updating Setupr..."
    cd "$INSTALL_DIR"
    git pull origin upgrage
    cd - >/dev/null
fi

if [[ "${Setupr_REF:-master}" != "master" ]]; then
  cd "$INSTALL_DIR"
  git fetch origin "${Setupr_REF:-stable}" && git checkout "${Setupr_REF:-stable}"
  cd - >/dev/null
fi

# Ensure proper permissions for user configs
USER_HOME=$(eval echo ~${SUDO_USER})
mkdir -p "${USER_HOME}/Downloads"
chown -R ${SUDO_USER}:${SUDO_USER} "${USER_HOME}/Downloads"

# Make scripts executable
chmod +x "$INSTALL_DIR/install.sh"
chmod +x "$INSTALL_DIR/check-version.sh"
chmod +x "$INSTALL_DIR"/modules/*/*.sh

# Set proper ownership
chown -R ${SUDO_USER}:${SUDO_USER} "$INSTALL_DIR"

echo "Installation starting..."

# Run install.sh with preserved environment variables
HOME="$USER_HOME" \
USER="$SUDO_USER" \
LOGNAME="$SUDO_USER" \
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin" \
sudo -E -H -u "$SUDO_USER" bash "$INSTALL_DIR/install.sh"
