#!/usr/bin/env bash
set -e

ascii_art=' 

 █████╗ ████████╗███████╗██╗     ██╗███████╗██████╗ 
██╔══██╗╚══██╔══╝██╔════╝██║     ██║██╔════╝██╔══██╗
███████║   ██║   █████╗  ██║     ██║█████╗  ██████╔╝
██╔══██║   ██║   ██╔══╝  ██║     ██║██╔══╝  ██╔══██╗
██║  ██║   ██║   ███████╗███████╗██║███████╗██║  ██║
╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝

'

echo -e "$ascii_art"
echo "=> Atelier is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Atelier..."
rm -rf ~/.local/share/atelier
git clone https://github.com/ByteTrix/Atelier.git ~/.local/share/atelier >/dev/null
if [[ "${ATELIER_REF:-master}" != "master" ]]; then
  cd ~/.local/share/atelier
  git fetch origin "${ATELIER_REF:-stable}" && git checkout "${ATELIER_REF:-stable}"
  cd - >/dev/null
fi

echo "Installation starting..."
source ~/.local/share/atelier/install.sh
