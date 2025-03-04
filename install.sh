#!/usr/bin/env bash
#
# Setupr Installation Script
# -----------------------
# Modern development environment setup tool
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/lib/utils.sh"

# Temporary files for configuration and selected scripts
CONFIG_TEMP="/tmp/setupr_config_temp.json"
SELECTED_SCRIPTS_FILE="/tmp/setupr_selected_scripts.txt"
REAL_USER="${SUDO_USER:-$USER}"
DEFAULT_SAVE_PATH="$HOME/Downloads/setupr-config-$(date +%Y%m%d-%H%M%S).json"

# Function to display a summary of selected packages
display_summary() {
  local config_file=$1
  
  print_section "📋 Installation Summary"
  
  # Get timestamp for display
  local timestamp=$(jq -r '.timestamp' "$config_file")
  echo "Configuration created: $timestamp"
  
  # Count packages by category
  local categories=$(jq -r '.packages[] | split("/")[0]' "$config_file" | sort | uniq -c)
  
  gum style \
    --foreground 99 \
    --margin "0 0 1 0" \
    "Selected packages by category:"
  
  echo "$categories" | while read -r count category; do
    if [ -n "$category" ]; then
      gum style \
        --foreground 212 \
        "• $category: $count package(s)"
    fi
  done
  
  # Total count
  local total=$(jq '.packages | length' "$config_file")
  gum style \
    --foreground 82 \
    --margin "1 0" \
    "Total: $total package(s) selected for installation"
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

# ASCII art logo with color
print_logo() {
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border double \
        --align center \
        --width 50 --margin "1 2" \
        'Setupr' \
        '────────────' \
        'Modern Development Environment'
}

# Print section header
print_section() {
    gum style \
        --foreground 99 \
        --bold \
        --margin "1 0" \
        "$1"
}

# Check if running with sudo
if [ "$EUID" -eq 0 ]; then
    gum style \
        --foreground 196 \
        --bold \
        --border-foreground 196 \
        --border thick \
        --align center \
        --width 50 --margin "1 2" \
        "Please do not run this script with sudo."
    exit 1
fi

# Clear screen and show welcome
clear
print_logo

# System check spinner
gum spin --spinner dot --title "Performing system check..." -- sleep 2

# Check for required commands
REQUIRED_COMMANDS=("gum" "jq" "git" "curl")
MISSING_COMMANDS=()

print_section "System Requirements"
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING_COMMANDS+=("$cmd")
    fi
done

if [ ${#MISSING_COMMANDS[@]} -gt 0 ]; then
    gum style \
        --foreground 196 \
        "Missing required commands: ${MISSING_COMMANDS[*]}"
    
    if gum confirm "Would you like to install missing dependencies?"; then
        sudo apt-get update
        sudo apt-get install -y "${MISSING_COMMANDS[@]}"
    else
        exit 1
    fi
fi

# Ensure Downloads directory exists
mkdir -p "$HOME/Downloads"

# Installation modes with modern styling
print_section "Installation Mode"
MODES=(
    "🚀 Auto Install (Recommended Setup)"
    "🔨 Interactive Installation (Choose options as you go)"
    "⚙️  Create New Configuration (Save selections for later)"
    "📂 Use Saved Configuration (Load previous selections)"
)

MODE=$(gum choose \
    --cursor.foreground="212" \
    --selected.foreground="212" \
    --header="Select installation mode:" \
    --header.foreground="99" \
    "${MODES[@]}")

print_section "Processing"

# Initialize arrays for selected scripts
declare -a VERIFIED_SCRIPTS=()

case "$MODE" in
    "🚀 Auto Install"*)
        if [ -f "${SCRIPT_DIR}/recommended-config.json" ]; then
            gum style \
                --foreground 99 \
                "📦 Loading recommended configuration..."
            
            # Clean up any existing temporary files
            rm -f "$SELECTED_SCRIPTS_FILE"
            
            # Read scripts from recommended config and store in temp file
            jq -r '.packages[]' "${SCRIPT_DIR}/recommended-config.json" | while read -r package; do
                module_path="${SCRIPT_DIR}/modules/${package}.sh"
                if [ -f "$module_path" ]; then
                    echo "$module_path" >> "$SELECTED_SCRIPTS_FILE"
                fi
            done
            
            # Set the config for display later
            cp "${SCRIPT_DIR}/recommended-config.json" "$CONFIG_TEMP"
        else
            log_error "Recommended configuration file not found!"
            exit 1
        fi
        ;;

    "🔨 Interactive Installation"*)
        # Create initial temporary files
        > "$SELECTED_SCRIPTS_FILE"
        
        # Create initial config JSON with current timestamp
        CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
        echo '{
          "mode": "Interactive Installation",
          "timestamp": "'"$CURRENT_TIME"'",
          "packages": []
        }' > "$CONFIG_TEMP"
        
        # Categories to process
        CATEGORIES=("languages" "cli" "containers" "ides" "browsers" "apps" "mobile" "config")
        
        for category in "${CATEGORIES[@]}"; do
            MENU_SCRIPT="${SCRIPT_DIR}/modules/${category}/menu.sh"
            if [ -f "$MENU_SCRIPT" ]; then
                # Show an animated spinner while loading the menu
                gum spin --spinner dot --title "Loading ${category} options..." -- sleep 1
                
                log_info "Launching ${category} menu..."
                # Capture selections from the menu script
                selections=$(bash "$MENU_SCRIPT")
                
                if [ -n "$selections" ]; then
                    # Append to selected scripts file
                    echo "$selections" >> "$SELECTED_SCRIPTS_FILE"
                    
                    # Process each selection for the JSON config
                    while IFS= read -r script_path; do
                        # Extract package name from script path
                        script_rel_path=${script_path#"${SCRIPT_DIR}/modules/"}
                        package_name="${script_rel_path%.sh}"
                        
                        # Add to config
                        jq --arg pkg "$package_name" '.packages += [$pkg]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && 
                        mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
                        
                        # Show a subtle animation for each selected package
                        echo "Selected: $package_name" | gum style --foreground 99
                    done <<< "$selections"
                fi
            else
                log_warn "No interactive menu found for ${category}; skipping."
            fi
        done
        
        # If no packages were selected, add a placeholder
        if [ "$(jq '.packages | length' "$CONFIG_TEMP")" -eq 0 ]; then
            jq '.packages += ["No packages selected"]' "$CONFIG_TEMP" > "${CONFIG_TEMP}.tmp" && 
            mv "${CONFIG_TEMP}.tmp" "$CONFIG_TEMP"
        fi
        
        # Save config to Downloads with correct permissions
        cp "$CONFIG_TEMP" "$DEFAULT_SAVE_PATH"
        chmod 644 "$DEFAULT_SAVE_PATH"
        
        log_info "Configuration saved to $DEFAULT_SAVE_PATH"
        ;;

    "⚙️  Create New Configuration"*)
        config_script="${SCRIPT_DIR}/modules/config/create-config.sh"
        if [ -f "$config_script" ] && [ -x "$config_script" ]; then
            bash "$config_script"
            gum style \
                --foreground 99 \
                "Configuration saved in Downloads folder. You can use it for installation later."
        else
            log_error "Configuration creator not found!"
        fi
        exit 0
        ;;

    "📂 Use Saved Configuration"*)
        CONFIGS=($(ls -1 "$HOME/Downloads"/setupr-*.json 2>/dev/null || true))
        
        if [ ${#CONFIGS[@]} -eq 0 ]; then
            gum style \
                --foreground 196 \
                "No saved configurations found in Downloads folder."
            exit 1
        fi

        # List available configurations
        print_section "Saved Configurations"
        CONFIG_FILE=$(gum choose \
            --cursor.foreground="212" \
            --selected.foreground="212" \
            --header="Select a configuration:" \
            --header.foreground="99" \
            "${CONFIGS[@]}")

        if [ -f "$CONFIG_FILE" ]; then
            gum spin --spinner dot --title "Loading configuration..." -- sleep 1
            
            # Clean any existing temp files
            > "$SELECTED_SCRIPTS_FILE"
            
            # Copy config to temp location
            cp "$CONFIG_FILE" "$CONFIG_TEMP"
            
            # Read packages from the config and map to script paths
            jq -r '.packages[]' "$CONFIG_FILE" | while read -r package; do
                # Convert package name to script path
                module_path="${SCRIPT_DIR}/modules/${package}.sh"
                if [ -f "$module_path" ]; then
                    echo "$module_path" >> "$SELECTED_SCRIPTS_FILE"
                else
                    log_warn "Script not found for package: $package"
                fi
            done
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

# If we have a selected scripts file with content
if [ -f "$SELECTED_SCRIPTS_FILE" ] && [ -s "$SELECTED_SCRIPTS_FILE" ]; then
    # Display a summary of what will be installed
    display_summary "$CONFIG_TEMP"
    
    # Verify each script exists and is executable
    print_section "Verifying Installation Scripts"
    while IFS= read -r script; do
        script_name=$(basename "$script" .sh)
        echo -n "Checking $script_name... " | gum style --foreground 99
        
        if [ -f "$script" ] && [ -x "$script" ] || chmod +x "$script" 2>/dev/null; then
            VERIFIED_SCRIPTS+=("$script")
            echo "✓" | gum style --foreground 82
        else
            echo "✗" | gum style --foreground 196
        fi
    done < "$SELECTED_SCRIPTS_FILE"

    # If we have verified scripts to execute
    if [ ${#VERIFIED_SCRIPTS[@]} -gt 0 ]; then
        # Confirm installation with attractive prompt
        if gum confirm "$(gum style --bold --foreground 99 "Ready to install $(gum style --bold --foreground 212 "${#VERIFIED_SCRIPTS[@]}") packages?")"; then
            # Create progress meter
            total=${#VERIFIED_SCRIPTS[@]}
            current=0
            failed=0

            print_section "🚀 Installing Packages"
            
            # Execute verified scripts
            for script in "${VERIFIED_SCRIPTS[@]}"; do
                ((current++))
                name=$(basename "$script" .sh)
                
                # Show progress with percentage
                progress=$((current * 100 / total))
                gum style \
                    --foreground 99 \
                    "[$current/$total] ($progress%) Installing: $name"
                
                if bash "$script"; then
                    gum style \
                        --foreground 82 \
                        "✓ $name installed successfully"
                else
                    gum style \
                        --foreground 196 \
                        "✗ Failed to install $name"
                    ((failed++))
                fi
                
                # Add a slight delay for visual effect
                sleep 0.5
            done

            # Show final status with animation
            print_section "Installation Complete"
            
            if [ "$failed" -eq 0 ]; then
                gum style \
                    --foreground 82 \
                    --bold \
                    --border normal \
                    --align center \
                    --width 50 --margin "1 2" \
                    "🎉 Your development environment is ready!" \
                    "" \
                    "All $total packages were successfully installed."
            else
                gum style \
                    --foreground 196 \
                    --bold \
                    --border normal \
                    --align center \
                    --width 50 --margin "1 2" \
                    "⚠️ Installation completed with $failed errors" \
                    "" \
                    "$(($total - $failed))/$total packages were successfully installed."
            fi
            
            # Cleanup temp files
            rm -f "$SELECTED_SCRIPTS_FILE" "$CONFIG_TEMP"
        else
            gum style \
                --foreground 99 \
                "Installation cancelled."
            exit 0
        fi
    else
        log_error "No valid installation scripts found!"
        exit 1
    fi
fi
