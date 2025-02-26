#!/usr/bin/env bash
set -euo pipefail
source ~/.local/share/atelier/lib/utils.sh

# Ensure the script is run with sudo.
if [[ $EUID -ne 0 ]]; then
  log_error "Please run this script with sudo."
  exit 1
fi

log_info "Starting Atelier installer..."

# Ensure Gum is installed for modern interactive menus.
if ! command -v gum &>/dev/null; then
  log_info "Gum is not installed. Installing Gum..."
  apt update && apt install -y wget gnupg2
  wget -qO- https://raw.githubusercontent.com/charmbracelet/gum/main/install.sh | bash
fi

# Use Gum to select installation mode.
mode=$(gum choose "Automatic (Beginner Mode)" "Advanced (Full Interactive Mode)")
log_info "Selected mode: $mode"

if [[ "$mode" == "Automatic (Beginner Mode)" ]]; then
  log_info "Running Automatic Installation..."
  
  # Run common scripts with default settings.
  bash system-update.sh
  bash essential-tools.sh
  bash flatpak-setup.sh
  
  # Install common language runtimes.
  bash modules/languages/install-python.sh
  bash modules/languages/install-node.sh
  
  # Install default IDE (Visual Studio Code).
  bash modules/ides/install-vscode.sh
  
  # Install default browsers.
  bash modules/browsers/install-chrome.sh
  bash modules/browsers/install-brave.sh
  
  # Install selected productivity/collaboration apps.
  bash modules/apps/install-notion.sh
  bash modules/apps/install-obsidian.sh
  bash modules/apps/install-vlc.sh
  bash modules/apps/install-xournal.sh
  bash modules/apps/install-localsend.sh
  bash modules/apps/install-whatsapp.sh
  bash modules/apps/install-spotify.sh
  bash modules/apps/install-dropbox.sh
  bash modules/apps/install-todoist.sh
  bash modules/apps/install-telegram.sh
  bash modules/apps/install-ulauncher.sh
  bash modules/apps/install-syncthing.sh
  
  # Install Docker from the containers module.
  bash modules/containers/install-docker.sh
  
  # Setup dotfiles and configure GNOME theme.
  bash modules/config/setup-dotfiles.sh
  bash modules/theme/install-gnome-theme.sh
  
  bash system-cleanup.sh

elif [[ "$mode" == "Advanced (Full Interactive Mode)" ]]; then
  log_info "Running Advanced Installation..."
  
  # Run the basic common tasks.
  bash system-update.sh
  bash essential-tools.sh
  bash flatpak-setup.sh
  
  # For each module category, launch its interactive menu (which uses Gum).
  for category in languages cli containers ides browsers apps mobile config theme; do
    if [ -f "./modules/${category}/menu.sh" ]; then
      log_info "Launching ${category} menu..."
      bash "./modules/${category}/menu.sh"
    else
      log_warn "No interactive menu found for ${category}; skipping."
    fi
  done
  
  bash system-cleanup.sh

else
  log_error "Invalid mode selected. Exiting."
  exit 1
fi
log_info "Atelier installation complete! Please log out and log back in (or reboot) for all changes to take effect."