#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/Setupr/lib/utils.sh

log_info "Installing essential system tools..."
apt update
apt install -y git curl wget zsh vim neovim htop tmux build-essential software-properties-common unzip xclip jq gnome-tweak-tool gnome-sushi dbus-x11 gpg apt-transport-https
log_info "Essential system tools installed."
