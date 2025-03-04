#!/usr/bin/env bash
#
# Telegram Installation
# ------------------
# Installs Telegram Desktop messaging application
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[telegram] Installing Telegram..."

# Add Telegram repository
if ! command -v telegram-desktop &> /dev/null; then
    # Install required dependencies
    log_info "[telegram] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y curl apt-transport-https

    # Download and add repository key
    log_info "[telegram] Adding Telegram repository..."
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/telegram-archive-keyring.gpg

    # Add repository
    echo "deb [signed-by=/usr/share/keyrings/telegram-archive-keyring.gpg] https://packages.cloud.google.com/apt telegram-desktop main" | sudo tee /etc/apt/sources.list.d/telegram-desktop.list

    # Update package lists and install Telegram
    sudo apt-get update
    sudo apt-get install -y telegram-desktop

    # Create desktop shortcut
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/telegram.desktop" << EOF
[Desktop Entry]
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
Exec=telegram-desktop -- %u
Icon=telegram
Terminal=false
Type=Application
Categories=Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF

    log_success "[telegram] Telegram Desktop installed successfully!"
else
    log_warn "[telegram] Telegram Desktop is already installed."
fi

# Verify installation
if command -v telegram-desktop &> /dev/null; then
    log_info "[telegram] Telegram Desktop installation verified."
    telegram-desktop --version
else
    log_error "[telegram] Telegram Desktop installation could not be verified."
    exit 1
fi
