#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check for Google Chrome
if ! command -v google-chrome &>/dev/null; then
    log_error "[apps/whatsapp] Google Chrome is required but not installed"
    return 1
fi

log_info "[apps/whatsapp] Installing WhatsApp..."

# Create required directories
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/Setupr/apps/icons

# Copy icon file
ICON_SOURCE="${SCRIPT_DIR}/icons/WhatsApp.png"
ICON_DEST=~/.local/share/Setupr/apps/icons/WhatsApp.png

if [ ! -f "$ICON_SOURCE" ]; then
    log_error "[apps/whatsapp] Icon file not found: $ICON_SOURCE"
    return 1
fi

if ! cp "$ICON_SOURCE" "$ICON_DEST"; then
    log_error "[apps/whatsapp] Failed to copy icon file"
    return 1
fi

# Create desktop entry for WhatsApp
log_info "[apps/whatsapp] Creating desktop entry for WhatsApp..."
DESKTOP_FILE=~/.local/share/applications/WhatsApp.desktop

if ! cat <<EOF >"$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=WhatsApp Messenger
Exec=google-chrome --app="https://web.whatsapp.com" --name=WhatsApp --class=Whatsapp
Terminal=false
Type=Application
Icon=$ICON_DEST
Categories=GTK;Network;InstantMessaging;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
EOF
then
    log_error "[apps/whatsapp] Failed to create desktop entry"
    return 1
fi

# Verify installation
if [ -f "$DESKTOP_FILE" ] && [ -f "$ICON_DEST" ]; then
    log_success "[apps/whatsapp] WhatsApp installation complete"
    return 0
else
    log_error "[apps/whatsapp] WhatsApp installation failed"
    return 1
fi
