#!/usr/bin/env bash
#
# Timezone Configuration
# --------------------
# Configure system timezone with interactive selection
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[timezone] Starting timezone configuration..."

# Get current timezone
CURRENT_TZ=$(timedatectl show --property=Timezone --value)
log_info "[timezone] Current timezone: $CURRENT_TZ"

# Get list of available timezones
TIMEZONES=($(timedatectl list-timezones))

# Use gum to create an interactive timezone selection
log_info "[timezone] Displaying timezone selection menu..."
SELECTED_TZ=$(gum filter \
    --header="🕒 Select a timezone (type to search):" \
    --header.foreground="99" \
    --placeholder="Start typing to search timezones..." \
    --height=15 \
    "${TIMEZONES[@]}")

# Check if a timezone was selected
if [ -z "$SELECTED_TZ" ]; then
    log_warn "[timezone] No timezone selected; keeping current timezone."
    exit 0
fi

# Set the timezone if different from current
if [ "$SELECTED_TZ" != "$CURRENT_TZ" ]; then
    log_info "[timezone] Setting timezone to: $SELECTED_TZ"
    sudo timedatectl set-timezone "$SELECTED_TZ"
    
    # Verify the change
    NEW_TZ=$(timedatectl show --property=Timezone --value)
    if [ "$NEW_TZ" = "$SELECTED_TZ" ]; then
        log_success "[timezone] Timezone successfully updated to: $SELECTED_TZ"
    else
        log_error "[timezone] Failed to update timezone"
        exit 1
    fi
else
    log_warn "[timezone] Selected timezone is already set"
fi

# Display current date and time
log_info "[timezone] Current date and time: $(date)"