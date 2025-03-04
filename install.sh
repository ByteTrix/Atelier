#!/usr/bin/env bash
set -euo pipefail

# Get script directory for portable installation
INSTALL_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

# Source shared utilities.
# Source shared utilities from lib directory
if [ -f "${INSTALL_DIR}/lib/utils.sh" ]; then
  source "${INSTALL_DIR}/lib/utils.sh"
else
  echo "ERROR: utils.sh not found!" >&2
  exit 1
fi

# Check for necessary permissions
if ! touch "${INSTALL_DIR}/test.permissions" 2>/dev/null; then
  log_error "Missing write permissions in installation directory"
  exit 1
fi
rm -f "${INSTALL_DIR}/test.permissions"

log_info "Starting Setupr installer..."

# Check distribution version.
source "./check-version.sh"

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

  # Enhanced installation with parallel execution and progress tracking
  declare -A INSTALL_STEPS=(
    ["Flatpak Setup"]="flatpak-setup.sh"
    ["Python Runtime"]="modules/languages/install-python.sh"
    ["Node.js Runtime"]="modules/languages/install-node.sh"
    ["VS Code IDE"]="modules/ides/install-vscode.sh"
    ["Chrome Browser"]="modules/browsers/install-chrome.sh"
    ["Brave Browser"]="modules/browsers/install-brave.sh"
    ["Productivity Apps"]="modules/apps/install-*.sh"
    ["Docker Engine"]="modules/containers/install-docker.sh"
    ["System Config"]="modules/config/setup-dotfiles.sh"
    ["GNOME Theme"]="modules/theme/install-gnome-theme.sh"
  )

  # Run installations in parallel with error handling
  log_info "Starting parallel installations..."
  gum spin --spinner dot --title "Preparing..." -- sleep 1

  for step in "${!INSTALL_STEPS[@]}"; do
    (
      script="${INSTALL_DIR}/${INSTALL_STEPS[$step]}"
      if [[ $script == *"*.sh" ]]; then
        # Handle wildcard expansions
        for f in $script; do
          log_info "Installing ${f##*/}..."
          if ! bash "$f"; then
            log_error "Failed to install ${f##*/}"
            exit 1
          fi
        done
      else
        log_info "Installing $step..."
        if ! bash "$script"; then
          log_error "Failed to install $step"
          exit 1
        fi
      fi
    ) &> >(gum format -t template "{{ Italic }}» {{ . }} {{- /}}" >> "${INSTALL_DIR}/install.log") &
  done

  # Show progress bar while installations run
  gum spin --spinner line --title "Installing components..." -- \
    bash -c 'while ps -p $(jobs -p) >/dev/null 2>&1; do sleep 1; done'

  # Final system cleanup
  bash "${INSTALL_DIR}/system-cleanup.sh"

  # Generate installation report
  log_info "Generating installation report..."
  {
    echo "Successful installations:"
    grep "INFO: Installed" "${INSTALL_DIR}/install.log" || true
    echo -e "\nWarnings:"
    grep "WARN:" "${INSTALL_DIR}/install.log" || true
    echo -e "\nErrors:"
    grep "ERROR:" "${INSTALL_DIR}/install.log" || true
  } | gum format > "${INSTALL_DIR}/installation-report.txt"

  # Show final status with improved formatting
  if gum confirm "Show detailed installation report?" --affirmative="Show" --negative="Skip"; then
    gum style --border rounded --padding "1 2" --border-foreground 212 < "${INSTALL_DIR}/installation-report.txt" | \
    gum pager
  fi

  # Add post-install checks
  log_info "Running post-installation verification..."
  gum spin --spinner moon --title "Verifying installations..." -- \
    bash -c '
      declare -A CHECKS=(
        ["Python"]="python3 --version"
        ["Node.js"]="node --version"
        ["Docker"]="docker --version"
        ["VS Code"]="code --version"
      )

      echo -e "Verification Results:\n" > "${INSTALL_DIR}/verification.txt"
      for name in "${!CHECKS[@]}"; do
        if ${CHECKS[$name]} &>/dev/null; then
          echo "✅ $name" >> "${INSTALL_DIR}/verification.txt"
        else
          echo "❌ $name" >> "${INSTALL_DIR}/verification.txt"
        fi
      done
    '

elif [[ "$mode" == "Advanced (Full Interactive Mode)" ]]; then
  log_info "Running Advanced Installation..."

  # Run basic common tasks.
  bash "${INSTALL_DIR}/system-update.sh"
  bash "${INSTALL_DIR}/essential-tools.sh"
  bash "${INSTALL_DIR}/flatpak-setup.sh"

  # Create a temporary file to collect selected script paths.
  SELECTED_SCRIPTS_FILE="/tmp/Setupr_selected_scripts.txt"
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

log_info "Setupr installation complete! Please log out and log back in (or reboot) for all changes to take effect."
