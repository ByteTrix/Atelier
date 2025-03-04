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
declare -a SELECTED_SCRIPTS=()
declare -a VERIFIED_SCRIPTS=()

case "$MODE" in
    "🚀 Auto Install"*)
        if [ -f "${SCRIPT_DIR}/recommended-config.json" ]; then
            gum style \
                --foreground 99 \
                "📦 Loading recommended configuration..."
            
            # Read scripts from recommended config
            while IFS= read -r script; do
                if [ -n "$script" ]; then
                    SELECTED_SCRIPTS+=("$script")
                fi
            done < <(jq -r '.selections | to_entries[] | .value | to_entries[] | .key' "${SCRIPT_DIR}/recommended-config.json")
        else
            log_error "Recommended configuration file not found!"
            exit 1
        fi
        ;;

    "🔨 Interactive Installation"*)
        MENUS=(
            "apps/menu.sh"
            "browsers/menu.sh"
            "cli/menu.sh"
            "config/menu.sh"
            "containers/menu.sh"
            "ides/menu.sh"
            "languages/menu.sh"
            "mobile/menu.sh"
            "theme/menu.sh"
        )

        for menu in "${MENUS[@]}"; do
            menu_path="${SCRIPT_DIR}/modules/$menu"
            if [ -f "$menu_path" ]; then
                gum spin --spinner dot --title "Loading ${menu%/*} options..." -- sleep 1
                
                # Collect selected scripts from menu
                while IFS= read -r script; do
                    if [ -n "$script" ]; then
                        SELECTED_SCRIPTS+=("$script")
                    fi
                done < <(bash "$menu_path")
            fi
        done
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
            
            # Read scripts from selected config
            while IFS= read -r script; do
                if [ -n "$script" ]; then
                    SELECTED_SCRIPTS+=("$script")
                fi
            done < <(jq -r '.selections | to_entries[] | .value | to_entries[] | .key' "$CONFIG_FILE")
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

# Verify selected scripts
if [ ${#SELECTED_SCRIPTS[@]} -gt 0 ]; then
    # Verify each script exists and is executable
    for script in "${SELECTED_SCRIPTS[@]}"; do
        if verified_path=$(verify_script "$script"); then
            VERIFIED_SCRIPTS+=("$verified_path")
        fi
    done

    # If we have verified scripts to execute
    if [ ${#VERIFIED_SCRIPTS[@]} -gt 0 ]; then
        # Show installation summary
        print_section "Installation Summary"
        echo "Components to be installed:"
        for script in "${VERIFIED_SCRIPTS[@]}"; do
            gum style \
                --foreground 212 \
                "• $(basename "$script")"
        done

        # Confirm installation
        if gum confirm "Would you like to proceed with the installation?"; then
            # Create progress meter
            total=${#VERIFIED_SCRIPTS[@]}
            current=0
            failed=0

            # Execute verified scripts
            for script in "${VERIFIED_SCRIPTS[@]}"; do
                ((current++))
                name=$(basename "$script")
                gum style \
                    --foreground 99 \
                    "[$current/$total] Installing: $name"
                
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
            done

            # Show final status
            print_section "Installation Complete"
            if [ "$failed" -eq 0 ]; then
                gum style \
                    --foreground 82 \
                    --bold \
                    --border normal \
                    --align center \
                    --width 50 --margin "1 2" \
                    "🎉 Your development environment is ready!"
            else
                gum style \
                    --foreground 196 \
                    --bold \
                    --border normal \
                    --align center \
                    --width 50 --margin "1 2" \
                    "⚠️ Installation completed with $failed errors"
            fi
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
