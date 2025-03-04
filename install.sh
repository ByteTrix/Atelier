#!/usr/bin/env bash
set -euo pipefail

# Set installation directory
INSTALL_DIR="/usr/local/share/Setupr"
CONFIG_FILE="${INSTALL_DIR}/setupr-config.json"
CONFIG_TEMP="/tmp/setupr_config_temp.json"
DOWNLOADS_DIR="$HOME/Downloads"
DEFAULT_SAVE_PATH="${DOWNLOADS_DIR}/setupr_config_$(date +%Y%m%d_%H%M%S).json"

# Export INSTALL_DIR for child scripts
export INSTALL_DIR

# Source shared utilities.
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
"${INSTALL_DIR}/check-version.sh"

# Determine if we're running GNOME.
RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)

if $RUNNING_GNOME; then
  # Prevent sleep/lock during installation.
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.session idle-delay 0
  echo "Get ready to make a few choices..."
fi

# Ensure Gum and jq are installed.
if ! command -v gum &>/dev/null; then
  bash "${INSTALL_DIR}/modules/cli/install-gum.sh"
fi

if ! command -v jq &>/dev/null; then
  bash "${INSTALL_DIR}/modules/cli/install-jq.sh"
fi

# Ask user if they want to upload a config
if gum confirm "Do you want to upload a configuration file?"; then
  log_info "Please select a configuration file from your Downloads directory"
  config_files=$(find "$DOWNLOADS_DIR" -name "setupr_config*.json" -type f -printf "%f\n" | sort -r)
  if [ -n "$config_files" ]; then
    selected_config=$(echo "$config_files" | gum choose --header "Select a configuration file:")
    if [ -n "$selected_config" ]; then
      cp "${DOWNLOADS_DIR}/${selected_config}" "$CONFIG_FILE"
      log_info "Configuration loaded from ${selected_config}"
    fi
  else
    log_warn "No configuration files found in Downloads directory"
  fi
fi

# Check for existing config
if [ -f "$CONFIG_FILE" ]; then
  if gum confirm "Found existing configuration. Would you like to use it?"; then
    display_summary "$CONFIG_FILE"
    if gum confirm "Proceed with this configuration?"; then
      config_data=$(load_config "$CONFIG_FILE")
      mode=$(echo "$config_data" | jq -r '.mode')
      log_info "Using saved configuration"
    else
      mode=$(gum choose --header "Select Installation Mode:" "Automatic (Beginner Mode)" "Advanced (Full Interactive Mode)")
    fi
  else
    mode=$(gum choose --header "Select Installation Mode:" "Automatic (Beginner Mode)" "Advanced (Full Interactive Mode)")
  fi
else
  mode=$(gum choose --header "Select Installation Mode:" "Automatic (Beginner Mode)" "Advanced (Full Interactive Mode)")
fi

log_info "Selected mode: $mode"

if [[ "$mode" == "Automatic (Beginner Mode)" ]]; then
  log_info "Running Automatic Installation..."

  # Create initial config JSON
  echo '{
    "mode": "Automatic (Beginner Mode)",
    "timestamp": "",
    "packages": []
  }' > "$CONFIG_TEMP"

  # Add timestamp
  jq --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '.timestamp = $ts' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"

  # Add default packages
  jq '.packages += ["Flatpak Setup", "Python Runtime", "Node.js Runtime", "VS Code IDE", "Chrome Browser", "Brave Browser", "Docker Engine", "System Config", "GNOME Theme"]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"

  # Move temp config to final location
  mv "$CONFIG_TEMP" "$CONFIG_FILE"

  # Save config to Downloads
  cp "$CONFIG_FILE" "$DEFAULT_SAVE_PATH"
  log_info "Configuration saved to $DEFAULT_SAVE_PATH"

  # Display installation summary
  display_summary "$CONFIG_FILE"
  
  if ! gum confirm "Proceed with installation?"; then
    log_info "Installation cancelled by user"
    exit 0
  fi

  # Enhanced installation with parallel execution and progress tracking
  declare -A INSTALL_STEPS=(
    ["Flatpak Setup"]="flatpak-setup.sh"
    ["Python Runtime"]="modules/languages/install-python.sh"
    ["Node.js Runtime"]="modules/languages/install-node.sh"
    ["VS Code IDE"]="modules/ides/install-vscode.sh"
    ["Chrome Browser"]="modules/browsers/install-chrome.sh"
    ["Brave Browser"]="modules/browsers/install-brave.sh"
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

elif [[ "$mode" == "Advanced (Full Interactive Mode)" ]]; then
  log_info "Running Advanced Installation..."

  # Run basic common tasks.
  bash "${INSTALL_DIR}/system-update.sh"
  bash "${INSTALL_DIR}/essential-tools.sh"
  bash "${INSTALL_DIR}/flatpak-setup.sh"

  # Create initial config JSON
  echo '{
    "mode": "Advanced (Full Interactive Mode)",
    "timestamp": "",
    "packages": []
  }' > "$CONFIG_TEMP"

  # Add timestamp
  jq --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '.timestamp = $ts' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"

  # Create a temporary file to collect selected script paths
  SELECTED_SCRIPTS_FILE="/tmp/Setupr_selected_scripts.txt"
  > "$SELECTED_SCRIPTS_FILE"

  # For each module category, launch its interactive menu and append selected script paths
  for category in languages cli containers ides browsers apps mobile config theme; do
    MENU_SCRIPT="${INSTALL_DIR}/modules/${category}/menu.sh"
    if [ -f "$MENU_SCRIPT" ]; then
      log_info "Launching ${category} menu..."
      selections=$(bash "$MENU_SCRIPT")
      if [ -n "$selections" ]; then
        echo "$selections" >> "$SELECTED_SCRIPTS_FILE"
        while IFS= read -r script; do
          # Extract package name from script path and add to config
          package_name="${category}/$(basename "${script/.sh/}")"
          jq --arg pkg "$package_name" '.packages += [$pkg]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
        done <<< "$selections"
      fi
    else
      log_warn "No interactive menu found for ${category}; skipping."
    fi
  done

  # If no packages were selected, add a placeholder
  if [ "$(jq '.packages | length' "$CONFIG_TEMP")" -eq 0 ]; then
    jq '.packages += ["No packages selected"]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
  fi

  # Move temp config to final location
  mv "$CONFIG_TEMP" "$CONFIG_FILE"

  # Save config to Downloads
  cp "$CONFIG_FILE" "$DEFAULT_SAVE_PATH"
  log_info "Configuration saved to $DEFAULT_SAVE_PATH"

  # Display installation summary
  display_summary "$CONFIG_FILE"
  
  if ! gum confirm "Proceed with installation?"; then
    log_info "Installation cancelled by user"
    exit 0
  fi

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
