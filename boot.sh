#!/usr/bin/env bash
set -euo pipefail

# Professional ASCII Art for Setupr Logo
ascii_art='
███████╗███████╗████████╗██╗   ██╗██████╗ ██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ ██╔══██╗
███████║███████╗   ██║   ╚██████╔╝██║     ██║  ██║
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝  ╚═╝
'

# Ensure the script is run with sudo (not directly as root)
if [ "$EUID" -eq 0 ] && [ -z "${SUDO_USER:-}" ]; then
    echo "Error: Run with sudo, not as root."
    exit 1
elif [ "$EUID" -ne 0 ]; then
    echo "Error: Run with sudo."
    exit 1
fi


# Install dependency: gum
install_dependencies() {
    if ! command -v gum &>/dev/null; then
        echo "Installing dependency: gum..."
        if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo apt-key add -; then
            echo "deb [arch=amd64] https://repo.charm.sh/apt/ * *" | \
                sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt-get update -o Dir::Etc::sourcelist="/etc/apt/sources.list.d/charm.list" \
                -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gum
        else
            echo "Error: Failed to add Charm repository key."
            exit 1
        fi
    fi
}

# Main installation variables
INSTALL_DIR="/usr/local/share/Setupr"
USER_HOME=$(eval echo ~${SUDO_USER})

# Execute setup functions
install_dependencies

# Prepare the user environment
mkdir -p "${USER_HOME}/Downloads"
chown -R "${SUDO_USER}:${SUDO_USER}" "${USER_HOME}/Downloads"
# Preserve and set essential environment variables
[ -n "${TERM:-}" ] && export TERM
export HOME="$USER_HOME"
export USER="$SUDO_USER"
export LOGNAME="$SUDO_USER"
export XDG_RUNTIME_DIR="/run/user/$(id -u ${SUDO_USER})"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

# Display logo and notification
echo -e "$ascii_art"
echo "=> Setupr is for fresh Ubuntu 24.04+ installations only!"
echo "Begin installation (ctrl+c to abort)..."

# Remove existing directory if it exists
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

# Clone fresh repository
mkdir -p "$INSTALL_DIR"
echo "Cloning Setupr..."
if ! git clone -b v2.2 https://github.com/ByteTrix/Setupr.git "$INSTALL_DIR"; then
    echo "Error: Failed to clone repository."
    exit 1
fi

# Set executable permissions and ownership
chmod +x "$INSTALL_DIR"/{install,check-version,system-update}.sh
chmod +x "$INSTALL_DIR"/modules/*/*.sh 2>/dev/null || true
chown -R "${SUDO_USER}:${SUDO_USER}" "$INSTALL_DIR"

# Source utility functions and run system update
source "${INSTALL_DIR}/lib/utils.sh"
log_info "Running system update..."
sudo -E TERM="$TERM" bash "$INSTALL_DIR/system-update.sh"

log_info "Starting Setupr installation..."
# Preserve TERM for proper terminal handling
[ -n "${TERM:-}" ] && export TERM

# Final command: run install.sh while preserving TERM
sudo -E TERM="$TERM" bash "$INSTALL_DIR/install.sh"
