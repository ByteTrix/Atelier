cat <<EOF >~/.local/share/atelier/modules/apps/WhatsApp.desktop
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=WhatsApp Messenger
Exec=google-chrome --app="https://web.whatsapp.com" --name=WhatsApp --class=Whatsapp
Terminal=false
Type=Application
Icon=/home/\$USER/.local/share/atelier/apps/icons/WhatsApp.png
Categories=GTK;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
EOF
