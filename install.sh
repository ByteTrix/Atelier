#!/usr/bin/env bash
# Setupr Installation Script - Package Selection Interface

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/lib/utils.sh"

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

# Print dry run banner if enabled
if [ "$DRY_RUN" -eq 1 ]; then
    gum style \
        --foreground 214 --bold --border-foreground 214 --border thick \
        --align center --width 50 --margin "1 2" \
        "🔍 DRY RUN MODE - No changes will be made"
fi

# Display installation modes
gum style --foreground 99 --bold --margin "1 0" "Installation Mode"
echo

MODES=(
    "🚀 Auto Install (Recommended)"
    "🔨 Interactive Installation"
    "⚙️  Save Configuration"
    "📂 Load Configuration"
)

# Display menu for mode selection
MODE=$(gum choose \
    --cursor.foreground="212" \
    --selected.foreground="82" \
    "${MODES[@]}")

gum style --foreground 99 --bold --margin "1 0" "Processing"
echo

case "$MODE" in
    "🚀 Auto Install"*)
        if [ -f "${SCRIPT_DIR}/recommended-config.json" ]; then
            gum style --foreground 99 "📦 Loading recommended configuration..."
            # Process recommended config
            tempfile=$(mktemp)
            gum style --foreground 99 "📦 Loading recommended configuration..."
            if jq -r '.packages[]' "${SCRIPT_DIR}/recommended-config.json" >"$tempfile"; then
                sudo bash "${SCRIPT_DIR}/install-pkg.sh" < "$tempfile"
            fi
            rm -f "$tempfile"
        else
            log_error "Recommended configuration not found!"
            exit 1
        fi
        ;;
    "🔨 Interactive Installation"*)
        if [ "$DRY_RUN" -eq 1 ]; then
            log_info "Dry run: Would run menu.sh"
            exit 0
        else
            # Run menu.sh and capture package selections from FD 3
            tempfile=$(mktemp)
            if bash "${SCRIPT_DIR}/menu.sh" >&2 3>"$tempfile"; then
                if [ -s "$tempfile" ]; then
                    gum style --foreground 99 "📦 Processing selections..."
                    cat "$tempfile" | sudo bash "${SCRIPT_DIR}/install-pkg.sh"
                else
                    log_error "No packages were selected or menu was cancelled"
                fi
            fi
            rm -f "$tempfile"
        fi
        ;;
    "⚙️  Save Configuration"*)
        # Run menu.sh in save config mode and capture package selections from FD 3
        SELECTIONS=$(mktemp)
        if bash "${SCRIPT_DIR}/menu.sh" --save-config >&2 3>"$SELECTIONS"; then
            if [ -s "$SELECTIONS" ]; then
                REAL_USER="${SUDO_USER:-$USER}"
                DOWNLOADS_DIR="/home/$REAL_USER/Downloads"
                
                CONFIG_NAME=$(sudo -u "$REAL_USER" gum input \
                    --placeholder "Enter configuration name (e.g., dev, media)" \
                    --value "myconfig")
                CONFIG_NAME=${CONFIG_NAME:-default}
                
                CONFIG_FILE="$DOWNLOADS_DIR/${CONFIG_NAME}-setupr.json"
                CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
                
                # Create configuration JSON
                jq -n \
                    --arg name "$CONFIG_NAME" \
                    --arg time "$CURRENT_TIME" \
                    --arg desc "Setupr configuration created on $CURRENT_TIME" \
                    --argjson pkgs "$(cat "$SELECTIONS" | tr '\n' ' ' | jq -R -s 'split(" ")')" \
                    '{name: $name, description: $desc, timestamp: $time, packages: $pkgs}' \
                    > "$CONFIG_FILE"
                
                chown "$REAL_USER:$REAL_USER" "$CONFIG_FILE"
                chmod 644 "$CONFIG_FILE"
                log_success "Configuration saved as '${CONFIG_NAME}-setupr.json'"
                log_info "File location: $CONFIG_FILE"
            else
                log_error "No packages were selected!"
                exit 1
            fi
        fi
        rm -f "$SELECTIONS"
        ;;
    "📂 Load Configuration"*)
        REAL_USER="${SUDO_USER:-$USER}"
        DOWNLOADS_DIR="/home/$REAL_USER/Downloads"
        configs=()

        while IFS= read -r file; do
            if [ -f "$file" ]; then
                name=$(basename "$file" | sed 's/-setupr\.json$//')
                timestamp=$(jq -r '.timestamp // "Unknown date"' "$file")
                configs+=("$name ($timestamp)")
            fi
        done < <(find "$DOWNLOADS_DIR" -name "*-setupr.json" -type f)
        
        if [ ${#configs[@]} -eq 0 ]; then
            log_error "No configuration files found in $DOWNLOADS_DIR!"
            exit 1
        fi

        gum style --foreground 99 --bold --margin "1 0" "Saved Configurations"
        echo
        
        selected=$(gum choose --cursor.foreground="212" \
            --selected.foreground="82" \
            --header.border="rounded" \
            --header.border-foreground="99" \
            "${configs[@]}")
        
        if [ -n "$selected" ]; then
            config_name=$(echo "$selected" | cut -d' ' -f1)
            config_file="$DOWNLOADS_DIR/${config_name}-setupr.json"
            
            if [ "$DRY_RUN" -eq 1 ]; then
                log_info "Dry run: Would install from $config_name"
                jq -r '.packages[]' "$config_file" | while read -r pkg; do
                    log_info "Would install: $pkg"
                done
            else
                gum style --foreground 99 "📦 Loading configuration..."
                # Extract and process packages from saved config
                jq -r '.packages[]' "$config_file" >/tmp/pkg_list
                if [ -s /tmp/pkg_list ]; then
                    sudo bash "${SCRIPT_DIR}/install-pkg.sh" < /tmp/pkg_list
                    rm -f /tmp/pkg_list
                fi
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

# Run cleanup if packages were installed
if [[ "$MODE" =~ ^"🚀 Auto Install"|"🔨 Interactive Installation"|"📂 Load Configuration" ]]; then
    "${SCRIPT_DIR}/system-cleanup.sh"
    log_success "Setup completed successfully!"
fi
