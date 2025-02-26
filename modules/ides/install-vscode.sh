#!/usr/bin/env bash
set -euo pipefail

# Automatically configure the Microsoft repository
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections


# Download the Microsoft GPG key, dearmor it, and install it.
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm -f packages.microsoft.gpg

# Add the Visual Studio Code repository to your sources list.
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code
