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
export HOME="$USER_HOME"
export USER="$SUDO_USER"
export LOGNAME="$SUDO_USER"
export XDG_RUNTIME_DIR="/run/user/$(id -u ${SUDO_USER})"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

# Display logo and notification
echo -e "$ascii_art"
echo "=> Setupr is for fresh Ubuntu 24.04+ installations only!"
echo "Begin installation (ctrl+c to abort)..."

# Clone or update the repository
if [ ! -d "$INSTALL_DIR/.git" ]; then
    mkdir -p "$INSTALL_DIR"
    echo "Cloning Setupr..."
    git clone https://github.com/ByteTrix/Setupr.git "$INSTALL_DIR" || {
        echo "Error: Failed to clone repository."
        exit 1
    }Begin installation (ctrl+c to abort)...
Updating Setupr...
remote: Enumerating objects: 4, done.
remote: Counting objects: 100% (4/4), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 4 (delta 2), reused 4 (delta 2), pack-reused 0 (from 0)
Unpacking objects: 100% (4/4), 685 bytes | 76.00 KiB/s, done.
From https://github.com/ByteTrix/Setupr
   db05be3..bc5c07c  v2.2       -> origin/v2.2
HEAD is now at bc5c07c terminal support
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:10 - Running system update...
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:10 - Starting system update...
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:11 - Updating package lists...
Hit:1 http://in.archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:3 http://in.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:4 http://in.archive.ubuntu.com/ubuntu noble-backports InRelease
Hit:5 https://ppa.launchpadcontent.net/agornostal/ulauncher/ubuntu noble InRelease
Hit:6 https://ppa.launchpadcontent.net/dotnet/backports/ubuntu noble InRelease
Hit:7 https://ppa.launchpadcontent.net/obsproject/obs-studio/ubuntu noble InRelease
Reading package lists... Done
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:14 - Upgrading system packages...
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:15 - Cleaning up...
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:16 - System update completed successfully.
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:16 - Starting Setupr installation...

Installation Mode



Processing


tput: unknown terminal "xterm-ghostty"
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:18 - Starting system cleanup...
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:18 - Cleaning package cache...
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:24 - Package cache cleanup complete (Before: 44K, After: 44K)
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:24 - Cleaning temporary files...
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:24 - Temporary files cleanup complete (Before: 1.3M, After: 1.3M)
\033[0;34m[INFO]\033[0m 2025-03-07 00:24:24 - Cleaning user cache...
kavin@MARK-2:~$
else
    echo "Updating Setupr..."
    cd "$INSTALL_DIR"
    # Update to default branch
    git fetch origin || { echo "Error: Failed to fetch updates."; exit 1; }
    DEFAULT_BRANCH=$(git remote show origin | grep "HEAD branch" | cut -d: -f2 | xargs)
    git reset --hard "origin/${DEFAULT_BRANCH}" || { echo "Error: Failed to update repository."; exit 1; }
    cd - >/dev/null
fi

# Set executable permissions and ownership
chmod +x "$INSTALL_DIR"/{install,check-version,system-update}.sh
chmod +x "$INSTALL_DIR"/modules/*/*.sh 2>/dev/null || true
chown -R "${SUDO_USER}:${SUDO_USER}" "$INSTALL_DIR"

# Source utility functions and run system update
source "${INSTALL_DIR}/lib/utils.sh"
log_info "Running system update..."
sudo -E bash "$INSTALL_DIR/system-update.sh"

log_info "Starting Setupr installation..."
# Final command: simply run bash install.sh
bash "$INSTALL_DIR/install.sh"
