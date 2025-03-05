#!/usr/bin/env bash
#
# Setupr Configuration Creator
# -------------------------
# Interactive utility to create and manage Setupr configurations
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Ensure Downloads directory exists
CONFIG_DIR="$HOME/Downloads"
mkdir -p "$CONFIG_DIR"

# Function to extract menu options from a menu.sh file
extract_menu_options() {
    local file="$1"
    local section="$2"
    local options=()
    
    if [ ! -f "$file" ]; then
        log_error "Menu file not found: $file"
        return 1
    fi
    
    # Read the file and extract options
    while IFS= read -r line; do
        if [[ $line =~ \[\"([^\"]+)\"\]=\"([^\"]+)\" ]]; then
            local description="${BASH_REMATCH[1]}"
            local script="${BASH_REMATCH[2]}"
            options+=("$description|$script")
        fi
    done < "$file"
    
    # Return options as newline-separated string
    printf "%s\n" "${options[@]}"
}

# Function to save configuration
save_config() {
    local config_name="$1"
    local config_file="$CONFIG_DIR/setupr-${config_name}.json"
    
    # Validate write permissions
    if ! touch "$config_file" 2>/dev/null; then
        log_error "Cannot write to $config_file. Please check permissions."
        return 1
    fi

    # Collect all selected scripts
    local packages=()
    for section in "${!SELECTIONS[@]}"; do
        if [ -n "${SELECTIONS[$section]}" ]; then
            while IFS='|' read -r desc script; do
                if [ -n "$script" ]; then
                    packages+=("$script")
                fi
            done <<< "${SELECTIONS[$section]}"
        fi
    done

    # Create JSON configuration
    {
        echo "{"
        echo "  \"name\": \"$config_name\","
        echo "  \"created\": \"$(date -Iseconds)\","
        echo "  \"description\": \"Custom configuration created with Setupr\","
        echo "  \"packages\": ["
        
        local first=true
        for package in "${packages[@]}"; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"$package\""
        done
        echo
        echo "  ]"
        echo "}"
    } > "$config_file" || {
        log_error "Failed to write configuration to $config_file"
        return 1
    }
    
    log_success "Configuration saved to: $config_file"
}

# Function to handle menu selection
handle_menu_selection() {
    local section="$1"
    local menu_file="$2"
    
    if [ ! -f "$menu_file" ]; then
        log_error "Menu file not found: $menu_file"
        return 1
    fi

    local options
    options=$(extract_menu_options "$menu_file" "$section")
    
    if [ -n "$options" ]; then
        SELECTIONS["$section"]=$(echo "$options" | gum choose --no-limit \
            --header "Select $section" \
            --header "Choose components to install:")
    else
        log_warn "No options found in $menu_file"
    fi
}

# Initialize selections associative array
declare -A SELECTIONS

# Main menu options
MAIN_MENU=(
    "📱 Applications"
    "🌐 Web Browsers"
    "🔧 CLI Tools"
    "⚙️ System Configuration"
    "🐳 Container Tools"
    "💻 IDEs & Editors"
    "🚀 Programming Languages"
    "📱 Mobile Development"
    "🎨 Theme & Appearance"
    "💾 Save Configuration"
    "📂 Load Configuration"
    "❌ Exit"
)

# Main menu loop
while true; do
    ACTION=$(gum choose --header "Setupr Configuration Creator" "${MAIN_MENU[@]}")
    
    case "$ACTION" in
        "📱 Applications")
            handle_menu_selection "apps" "${SCRIPT_DIR}/../apps/menu.sh"
            ;;
        "🌐 Web Browsers")
            handle_menu_selection "browsers" "${SCRIPT_DIR}/../browsers/menu.sh"
            ;;
        "🔧 CLI Tools")
            handle_menu_selection "cli" "${SCRIPT_DIR}/../cli/menu.sh"
            ;;
        "⚙️ System Configuration")
            handle_menu_selection "config" "${SCRIPT_DIR}/../config/menu.sh"
            ;;
        "🐳 Container Tools")
            handle_menu_selection "containers" "${SCRIPT_DIR}/../containers/menu.sh"
            ;;
        "💻 IDEs & Editors")
            handle_menu_selection "ides" "${SCRIPT_DIR}/../ides/menu.sh"
            ;;
        "🚀 Programming Languages")
            handle_menu_selection "languages" "${SCRIPT_DIR}/../languages/menu.sh"
            ;;
        "📱 Mobile Development")
            handle_menu_selection "mobile" "${SCRIPT_DIR}/../mobile/menu.sh"
            ;;
        "🎨 Theme & Appearance")
            handle_menu_selection "theme" "${SCRIPT_DIR}/../theme/menu.sh"
            ;;
        "💾 Save Configuration")
            CONFIG_NAME=$(gum input --placeholder "Enter configuration name" --header "Save Configuration")
            if [ -n "$CONFIG_NAME" ]; then
                save_config "$CONFIG_NAME"
            else
                log_error "Configuration name cannot be empty"
            fi
            ;;
        "📂 Load Configuration")
            CONFIGS=($(ls -1 "$CONFIG_DIR"/setupr-*.json 2>/dev/null || true))
            if [ ${#CONFIGS[@]} -eq 0 ]; then
                log_warn "No saved configurations found in Downloads"
                continue
            fi
            
            CONFIG_FILE=$(gum choose --header "Select Configuration" "${CONFIGS[@]}")
            if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
                if command -v jq &>/dev/null; then
                    # Clear existing selections
                    SELECTIONS=()
                    
                    # Load selections from configuration
                    while IFS="=" read -r section content; do
                        SELECTIONS["$section"]="$content"
                    done < <(jq -r '.selections | to_entries | .[] | .key + "=" + (.value | @sh)' "$CONFIG_FILE")
                    
                    log_success "Configuration loaded from: $CONFIG_FILE"
                else
                    log_error "jq is required for loading configurations"
                fi
            else
                log_error "Invalid configuration file selected"
            fi
            ;;
        "❌ Exit")
            log_info "Configuration creator exited"
            exit 0
            ;;
        *)
            log_error "Invalid selection"
            ;;
    esac
done