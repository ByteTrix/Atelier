#!/usr/bin/env bash
set -euo pipefail

source ~/.local/share/Setupr/lib/utils.sh

log_info "[apps/whatsapp] Installing WhatsApp..."

# Create a desktop entry for WhatsApp
log_info "[apps/whatsapp] Creating desktop entry for WhatsApp..."
cat <<EOF >~/.local/share/applications/WhatsApp.desktop
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=WhatsApp Messenger
Exec=google-chrome --app="https://web.whatsapp.com" --name=WhatsApp --class=Whatsapp
Terminal=false
Type=Application
Icon=/home/\$USER/.local/share/Setupr/apps/icons/WhatsApp.png
Categories=GTK;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
EOF

log_info "[apps/whatsapp] WhatsApp installation complete."
