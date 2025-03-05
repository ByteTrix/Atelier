#!/usr/bin/env bash
#
# Setupr Installation Script
# ---------------------------
# Modern development environment setup tool
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

# Parse command line arguments
DRY_RUN=0
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
    esac
done

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/lib/utils.sh"

# Print dry run banner if enabled
if [ "$DRY_RUN" -eq 1 ]; then
    gum style \
        --foreground 214 --bold --border-foreground 214 --border thick \
        --align center --width 50 --margin "1 2" \
        "🔍 DRY RUN MODE - No changes will be made"
fi

# Temporary files for configuration and selected scripts
CONFIG_TEMP="/tmp/setupr_config_temp.json"
SELECTED_SCRIPTS_FILE="/tmp/setupr_selected_scripts.txt"
REAL_USER="${SUDO_USER:-$USER}"
DEFAULT_SAVE_PATH="$HOME/Downloads/setupr-config-$(date +%Y%m%d-%H%M%S).json"

# Helper function to add a package to the temporary selected scripts file
add_script_to_temp() {
  local package="$1"
  local module_path="${SCRIPT_DIR}/modules/${package}.sh"
  if [ -f "$module_path" ]; then
    echo "$module_path" >> "$SELECTED_SCRIPTS_FILE"
  else
    log_warn "Module not found for package: $package (expected at: $module_path)"
  fi
}

# Function to display a summary of selected packages
display_summary() {
  local config_file=$1
  
  print_section "📋 Installation Summary"
  
  # Get timestamp for display
  local timestamp
  timestamp=$(jq -r '.timestamp' "$config_file")
  echo "Configuration created: $timestamp"
  
  # Count packages by category
  local categories
  categories=$(jq -r '.packages[] | split("/")[0]' "$config_file" | sort | uniq -c)
  
  gum style --foreground 99 --margin "0 0 1 0" "Selected packages by category:"
  
  echo "$categories" | while read -r count category; do
    if [ -n "$category" ]; then
      gum style --foreground 212 "• $category: $count package(s)"
    fi
  done
  
  # Total count
  local total
  total=$(jq '.packages | length' "$config_file")
  gum style --foreground 82 --margin "1 0" "Total: $total package(s) selected for installation"
}

# Function to verify script exists and is executable
verify_script() {
  local script="$1"
  local full_path="${SCRIPT_DIR}/modules/$script"
  
  if [ ! -f "$full_path" ]; then
    log_error "Script not found: $script"
    return 1
  fi
  
  if [ ! -x "$full_path" ]; then
    log_info "Making script executable: $script"
    chmod +x "$full_path"
  fi
  
  echo "$full_path"
  return 0
}

# Function to test script execution (bash syntax check)
test_script_execution() {
  local script="$1"
  
  if [ ! -f "$script" ]; then
    return 1
  fi
  
  if [ ! -x "$script" ]; then
    chmod +x "$script" 2>/dev/null || return 1
  fi
  
  bash -n "$script" 2>/dev/null || return 1
  return 0
}

# Print section header
print_section() {
  gum style --foreground 99 --bold --margin "1 0" "$1"
}

# Check execution context
if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
    gum style --foreground 196 --bold --border-foreground 196 --border thick --align center --width 50 --margin "1 2" \
        "Please run with sudo, not as root directly."
    exit 1
fi



# Initialize sudo session with simplified approach
init_sudo_session

# Check and install required dependencies
REQUIRED_COMMANDS=("gum" "jq" "git" "curl")
missing_deps=()

# Check for required commands
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        missing_deps+=("$cmd")
    fi
done

# Install missing dependencies if needed
if [ ${#missing_deps[@]} -gt 0 ]; then
    gum style --foreground 196 "Missing required commands: ${missing_deps[*]}"
    if gum confirm "Install missing dependencies?"; then
        gum spin --spinner dot --title "Installing dependencies..." -- bash -c '
            sudo_exec apt-get update -qq
            sudo_exec apt-get install -y '"${missing_deps[*]}"'
        '
    else
        exit 1
    fi
fi

# Ensure Downloads directory exists
mkdir -p "$HOME/Downloads"

# Initialize config file with current timestamp
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo '{
  "mode": "",
  "timestamp": "'"$CURRENT_TIME"'",
  "packages": []
}' > "$CONFIG_TEMP"

# Clear any previous temporary selected scripts file
: > "$SELECTED_SCRIPTS_FILE"

# Export sudo_exec function for child processes if in sudo context
if is_sudo_context; then
    export SETUPR_SUDO=1
    export -f sudo_exec
fi

# Installation modes with modern styling
print_section "Installation Mode"
MODES=(
  "🚀 Auto Install (Recommended Setup)"
  "🔨 Interactive Installation (Choose options as you go)"
  "⚙️  Create New Configuration (Save selections for later)"
  "📂 Use Saved Configuration (Load previous selections)"
)

MODE=$(gum choose --cursor.foreground="212" --selected.foreground="212" \
  --header="Select installation mode:" "${MODES[@]}")

print_section "Processing"

# Initialize array for verified scripts
declare -a VERIFIED_SCRIPTS=()

case "$MODE" in
  "🚀 Auto Install"*)
    echo '{"mode": "Auto Install", "packages": []}' > "$CONFIG_TEMP"
    
    if [ -f "${SCRIPT_DIR}/recommended-config.json" ]; then
      gum style --foreground 99 "📦 Loading recommended configuration..."
      cp "${SCRIPT_DIR}/recommended-config.json" "$CONFIG_TEMP"
      
      while IFS= read -r package; do
        add_script_to_temp "$package"
      done < <(jq -r '.packages[]' "$CONFIG_TEMP")
    else
      log_error "Recommended configuration file not found!"
      exit 1
    fi
    ;;
  "🔨 Interactive Installation"*)
    echo '{"mode": "Interactive Installation"}' | jq -s '.[0] * input' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
    CATEGORIES=("languages" "cli" "containers" "ides" "browsers" "apps" "mobile" "config")
    for category in "${CATEGORIES[@]}"; do
      MENU_SCRIPT="${SCRIPT_DIR}/modules/${category}/menu.sh"
      if [ -f "$MENU_SCRIPT" ]; then
        gum spin --spinner dot --title "Loading ${category} options..." -- sleep 1
        log_info "Launching ${category} menu..."
        selections=$(bash "$MENU_SCRIPT")
        if [ -n "$selections" ]; then
          while IFS= read -r script_path; do
            script_rel_path=${script_path#"${SCRIPT_DIR}/modules/"}
            package_name="${script_rel_path%.sh}"
            add_script_to_temp "$package_name"
            jq --arg pkg "$package_name" '.packages += [$pkg]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
            echo "Selected: $package_name" | gum style --foreground 99
          done <<< "$selections"
        fi
      else
        log_warn "No interactive menu found for ${category}; skipping."
      fi
    done
    if [ "$(jq '.packages | length' "$CONFIG_TEMP")" -eq 0 ]; then
      jq '.packages += ["No packages selected"]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
    fi
    cp "$CONFIG_TEMP" "$DEFAULT_SAVE_PATH"
    chmod 644 "$DEFAULT_SAVE_PATH"
    log_info "Configuration saved to $DEFAULT_SAVE_PATH"
    ;;
  "⚙️  Create New Configuration"*)
    config_script="${SCRIPT_DIR}/modules/config/create-config.sh"
    if [ -f "$config_script" ] && [ -x "$config_script" ]; then
      bash "$config_script"
    else
      log_error "Configuration creator not found!"
      exit 1
    fi
    ;;
  "📂 Use Saved Configuration"*)
    CONFIGS=($(ls -1 "$HOME/Downloads"/setupr-config-*.json 2>/dev/null || true))
    if [ ${#CONFIGS[@]} -eq 0 ]; then
      gum style --foreground 196 --bold --border-foreground 196 --border thick --align center --width 50 --margin "1 2" \
        "No saved configurations found in Downloads folder."
      exit 1
    fi
    print_section "Saved Configurations"
    CONFIG_FILE=$(gum choose --cursor.foreground="212" --selected.foreground="212" --header="Select a configuration:" "${CONFIGS[@]}")
    if [ -f "$CONFIG_FILE" ]; then
      gum spin --spinner dot --title "Loading configuration..." -- sleep 1
      cp "$CONFIG_FILE" "$CONFIG_TEMP"
      log_info "Extracting package information from config file"
      jq -r '.packages[]' "$CONFIG_FILE" | while read -r package; do
        add_script_to_temp "$package"
        log_info "Added script for package: $package"
      done
      script_count=$(wc -l < "$SELECTED_SCRIPTS_FILE")
      if [ "$script_count" -eq 0 ]; then
        log_error "No valid installation scripts found in configuration!"
        exit 1
      else
        log_info "Found $script_count installation scripts to process"
      fi
    else
      log_error "Configuration file not found!"
      exit 1
    fi
    ;;
  *)
    log_error "Invalid mode selected."
    exit 1
    ;;
esac

# Verify selected scripts exist and are executable
if [ -f "$SELECTED_SCRIPTS_FILE" ] && [ -s "$SELECTED_SCRIPTS_FILE" ]; then
  print_section "Verifying Installation Scripts"
  while IFS= read -r script; do
    script_name=$(basename "$script" .sh)
    echo -n "Checking $script_name... " | gum style --foreground 99
    if [ -f "$script" ]; then
      if [ ! -x "$script" ]; then
        chmod +x "$script" || {
          log_error "Failed to make $script executable."
          continue
        }
      fi
      VERIFIED_SCRIPTS+=("$script")
      echo "✓" | gum style --foreground 82
    else
      echo "(Not found)" | gum style --foreground 196
    fi
  done < "$SELECTED_SCRIPTS_FILE"
else
  log_error "No valid installation scripts found!"
  exit 1
fi

# Execute or simulate all selected scripts
if [ "$DRY_RUN" -eq 1 ]; then
    print_section "🔍 Installation Simulation"
    log_info "The following modules would be installed:"
    
    while IFS= read -r script; do
        if [ -n "$script" ]; then
            module_name=$(basename "$script" .sh)
            category=$(dirname "$script" | grep -oP "modules/\K[^/]+")
            gum style --foreground 99 "  [$category] Would install: $module_name"
            
            # Test script for syntax errors
            if bash -n "$script"; then
                echo "  ✓ Script validation passed" | gum style --foreground 82
            else
                echo "  ✗ Script validation failed" | gum style --foreground 196
            fi
        fi
    done < "$SELECTED_SCRIPTS_FILE"
    
    log_info "Dry run completed. No changes were made."
else
    # Real execution mode
    log_info "Bulk executing selected modules..."
    
    # Export sudo functions for child processes
    export -f sudo_exec
    export SETUPR_SUDO=1
    
    # Track installation results
    declare -A install_results
    failed_installs=0

    while IFS= read -r script; do
        if [ -n "$script" ]; then
            script_name=$(basename "$script" .sh)
            category=$(dirname "$script" | grep -oP "modules/\K[^/]+")
            log_info "[$category] Installing $script_name..."
            
            # Execute script in subshell to prevent it from stopping the main process
            if (set +e; source "${SCRIPT_DIR}/lib/utils.sh" && bash "$script"); then
                install_results["$script_name"]="✓ Success"
                log_success "[$category] Successfully installed $script_name"
            else
                install_status=$?
                install_results["$script_name"]="✗ Failed (exit code: $install_status)"
                log_error "[$category] Failed to install $script_name (exit code: $install_status)"
                ((failed_installs++))
            fi
            
            # Small delay to ensure log readability
            sleep 1
        fi
    done < "$SELECTED_SCRIPTS_FILE"

    # Print installation summary
    print_section "Installation Summary"
    for script_name in "${!install_results[@]}"; do
        if [[ ${install_results[$script_name]} == *"Success"* ]]; then
            gum style --foreground 82 "  $script_name: ${install_results[$script_name]}"
        else
            gum style --foreground 196 "  $script_name: ${install_results[$script_name]}"
        fi
    done

    if [ $failed_installs -gt 0 ]; then
        log_warn "$failed_installs installation(s) failed. Check the logs above for details."
    else
        log_success "All installations completed successfully!"
    fi
fi

# Cleanup temporary files
rm -f "$SELECTED_SCRIPTS_FILE"

# Run final system cleanup
source "${SCRIPT_DIR}/lib/utils.sh"
bash "${SCRIPT_DIR}/system-cleanup.sh"
