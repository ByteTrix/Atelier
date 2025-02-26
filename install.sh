#!/usr/bin/env bash
set -euo pipefail

# Define the installation directory.
INSTALL_DIR="${HOME}/.local/share/atelier"

# Source shared utilities.
source "${INSTALL_DIR}/lib/utils.sh"

# Ensure the script is run with sudo.
if [[ $EUID -ne 0 ]]; then
  log_error "Please run this script with sudo."
  exit 1
fi

log_info "Starting Atelier installer..."

# Check distribution version.
source "${INSTALL_DIR}/check-version.sh"

# Determine if we're running GNOME.
RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)

if $RUNNING_GNOME; then
  # Prevent sleep/lock during installation.
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.session idle-delay 0

  echo "Get ready to make a few choices..."
  
fi

# -------------------------
# Begin mode selection via Gum.
# -------------------------
# Ensure Gum is installed.
if ! command -v gum &>/dev/null; then
  bash "${INSTALL_DIR}/modules/cli/install-gum.sh"
fi

# Use Gum to select installation mode.
mode=$(gum choose --header "Select Installation Mode:" "Automatic (Beginner Mode)" "Advanced (Full Interactive Mode)")
log_info "Selected mode: $mode"

if [[ "$mode" == "Automatic (Beginner Mode)" ]]; then
  log_info "Running Automatic Installation..."

  # Run common scripts with default settings.
  bash "${INSTALL_DIR}/flatpak-setup.sh"

  # Install default language runtimes.
  bash "${INSTALL_DIR}/modules/languages/install-python.sh"
  bash "${INSTALL_DIR}/modules/languages/install-node.sh"

  # Install default IDE (Visual Studio Code).
  bash "${INSTALL_DIR}/modules/ides/install-vscode.sh"

  # Install default browsers.
  bash "${INSTALL_DIR}/modules/browsers/install-chrome.sh"
  bash "${INSTALL_DIR}/modules/browsers/install-brave.sh"

  # Install selected productivity/collaboration apps.
  bash "${INSTALL_DIR}/modules/apps/install-notion.sh"
  bash "${INSTALL_DIR}/modules/apps/install-obsidian.sh"
  bash "${INSTALL_DIR}/modules/apps/install-vlc.sh"
  bash "${INSTALL_DIR}/modules/apps/install-xournal.sh"
  bash "${INSTALL_DIR}/modules/apps/install-localsend.sh"
  bash "${INSTALL_DIR}/modules/apps/install-whatsapp.sh"
  bash "${INSTALL_DIR}/modules/apps/install-spotify.sh"
  bash "${INSTALL_DIR}/modules/apps/install-telegram.sh"
  bash "${INSTALL_DIR}/modules/apps/install-ulauncher.sh"
  bash "${INSTALL_DIR}/modules/apps/install-syncthing.sh"

  # Install Docker.
  bash "${INSTALL_DIR}/modules/containers/install-docker.sh"

  # Setup dotfiles and GNOME theme.
  bash "${INSTALL_DIR}/modules/config/setup-dotfiles.sh"
  bash "${INSTALL_DIR}/modules/theme/install-gnome-theme.sh"

  bash "${INSTALL_DIR}/system-cleanup.sh"

elif [[ "$mode" == "Advanced (Full Interactive Mode)" ]]; then
  log_info "Running Advanced Installation..."

  # Run basic common tasks.
  bash "${INSTALL_DIR}/system-update.sh"
  bash "${INSTALL_DIR}/essential-tools.sh"
  bash "${INSTALL_DIR}/flatpak-setup.sh"

  # Create a temporary file to collect selected script paths.
  SELECTED_SCRIPTS_FILE="/tmp/atelier_selected_scripts.txt"
  > "$SELECTED_SCRIPTS_FILE"

  # For each module category, launch its interactive menu and append selected script paths.
  for category in languages cli containers ides browsers apps mobile config theme; do
    MENU_SCRIPT="${INSTALL_DIR}/modules/${category}/menu.sh"
    if [ -f "$MENU_SCRIPT" ]; then
      log_info "Launching ${category} menu..."
      bash "$MENU_SCRIPT" >> "$SELECTED_SCRIPTS_FILE"
    else
      log_warn "No interactive menu found for ${category}; skipping."
    fi
  done

  # Bulk execute all selected scripts.
  log_info "Bulk executing selected modules..."
  while IFS= read -r script; do
    if [ -n "$script" ]; then
      log_info "Executing $script..."
      bash "$script"
    fi
  done < "$SELECTED_SCRIPTS_FILE"
  rm -f "$SELECTED_SCRIPTS_FILE"

  bash "${INSTALL_DIR}/system-cleanup.sh"
else
  log_error "Invalid mode selected. Exiting."
  exit 1
fi

if $RUNNING_GNOME; then
  # Revert idle and lock settings.
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.session idle-delay 300
fi

log_info "Atelier installation complete! Please log out and log back in (or reboot) for all changes to take effect."
