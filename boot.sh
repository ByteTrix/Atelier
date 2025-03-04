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

echo -e "$ascii_art"
echo "=> Setupr is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Setupr..."
rm -rf ~/.local/share/Setupr
git clone https://github.com/ByteTrix/Setupr.git ~/.local/share/Setupr >/dev/null
if [[ "${Setupr_REF:-master}" != "master" ]]; then
  cd ~/.local/share/Setupr
  git fetch origin "${Setupr_REF:-stable}" && git checkout "${Setupr_REF:-stable}"
  cd - >/dev/null
fi

echo "Installation starting..."
source ~/.local/share/Setupr/install.sh
