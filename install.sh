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

# Print section header
print_section() {
    gum style --foreground 99 --bold --margin "1 0" "$1"
}

# Print dry run banner if enabled
if [ "$DRY_RUN" -eq 1 ]; then
    gum style \
        --foreground 214 --bold --border-foreground 214 --border thick \
        --align center --width 50 --margin "1 2" \
        "🔍 DRY RUN MODE - No changes will be made"
fi

# Get real user's home directory
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
DOWNLOADS_DIR="$REAL_HOME/Downloads"

# Ensure Downloads directory exists
mkdir -p "$DOWNLOADS_DIR"
chown "$REAL_USER:$REAL_USER" "$DOWNLOADS_DIR"

# Check execution context
if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
    gum style --foreground 196 --bold --border-foreground 196 --border thick --align center --width 50 --margin "1 2" \
        "Please run with sudo, not as root directly."
    exit 1
fi

# Initialize sudo session
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
            sudo apt-get update -qq
            sudo apt-get install -y '"${missing_deps[*]}"'
        '
    else
        exit 1
    fi
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

case "$MODE" in
    "🚀 Auto Install"*)
        if [ -f "${SCRIPT_DIR}/recommended-config.json" ]; then
            gum style --foreground 99 "📦 Loading recommended configuration..."
            jq -r '.packages[]' "${SCRIPT_DIR}/recommended-config.json" | tr ' ' '\n' | ./install-pkg.sh
        else
            log_error "Recommended configuration file not found!"
            exit 1
        fi
        ;;
    "🔨 Interactive Installation"*)
        # Use the new menu system
        if [ "$DRY_RUN" -eq 1 ]; then
            log_info "Dry run: Would run menu.sh"
            exit 0
        else
            bash "${SCRIPT_DIR}/menu.sh" | ./install-pkg.sh
        fi
        ;;
    "⚙️  Create New Configuration"*)
        # First get selections from menu
        print_section "Select Packages for Configuration"
        
        # Get selections from menu without installing
        SELECTIONS=$(mktemp)
        bash "${SCRIPT_DIR}/menu.sh" > "$SELECTIONS"
        
        # Only proceed if selections were made
        if [ -s "$SELECTIONS" ]; then
            print_section "Name Your Configuration"
            # Now ask for configuration name
            CONFIG_NAME=$(sudo -u "$REAL_USER" gum input --placeholder "Enter a name for this configuration (e.g., dev, media)" --value "myconfig")
            if [ -z "$CONFIG_NAME" ]; then
                CONFIG_NAME="default"
            fi
            
            # Format the filename
            CONFIG_FILE="$DOWNLOADS_DIR/${CONFIG_NAME}-setupr.json"
            
            # Save current time
            CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
            
            # Create configuration JSON
            CONFIG_JSON=$(cat <<EOF
{
    "name": "$CONFIG_NAME",
    "description": "Setupr configuration created on $CURRENT_TIME",
    "timestamp": "$CURRENT_TIME",
    "packages": $(cat "$SELECTIONS" | tr '\n' ' ' | jq -R -s -c 'split(" ")')
}
EOF
)
            # Save to Downloads directory
            echo "$CONFIG_JSON" > "$CONFIG_FILE"
            chown "$REAL_USER:$REAL_USER" "$CONFIG_FILE"
            chmod 644 "$CONFIG_FILE"
            
            log_success "Configuration saved as '${CONFIG_NAME}-setupr.json'"
            log_info "File location: $CONFIG_FILE"
            log_info "You can install this configuration later using 'Use Saved Configuration' option"
            
            # Cleanup
            rm -f "$SELECTIONS"
        else
            log_error "No packages were selected!"
            rm -f "$SELECTIONS"
            exit 1
        fi
        ;;
    "📂 Use Saved Configuration"*)
        # Look for *-setupr.json files in Downloads
        configs=()
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                name=$(basename "$file" | sed 's/-setupr\.json$//')
                timestamp=$(jq -r '.timestamp // "Unknown date"' "$file")
                desc=$(jq -r '.description // "No description available"' "$file")
                configs+=("$name ($timestamp)")
            fi
        done < <(find "$DOWNLOADS_DIR" -name "*-setupr.json" -type f)
        
        if [ ${#configs[@]} -eq 0 ]; then
            gum style --foreground 196 --bold --border-foreground 196 --border thick --align center --width 50 --margin "1 2" \
                "No configuration files found in Downloads!"
            exit 1
        fi
        
        print_section "Saved Configurations"
        
        # Let user select a configuration
        selected=$(gum choose --cursor.foreground="212" --selected.foreground="212" \
            --header="Select a configuration:" "${configs[@]}")
        
        if [ -n "$selected" ]; then
            # Extract config name from selection
            config_name=$(echo "$selected" | cut -d' ' -f1)
            config_file="$DOWNLOADS_DIR/${config_name}-setupr.json"
            
            if [ "$DRY_RUN" -eq 1 ]; then
                log_info "Dry run: Would install packages from $config_name"
                jq -r '.packages[]' "$config_file" | while read -r pkg; do
                    log_info "Would install: $pkg"
                done
            else
                log_info "Installing packages from ${config_name}-setupr.json..."
                jq -r '.packages[]' "$config_file" | ./install-pkg.sh
            fi
        else
            log_error "No configuration selected!"
            exit 1
        fi
        ;;
    *)
        log_error "Invalid mode selected."
        exit 1
        ;;
esac

# Run final system cleanup only if we installed packages
if [[ "$MODE" =~ ^"🚀 Auto Install"|"🔨 Interactive Installation"|"📂 Use Saved Configuration" ]]; then
    bash "${SCRIPT_DIR}/system-cleanup.sh"
    log_success "Setup completed successfully!"
fi
