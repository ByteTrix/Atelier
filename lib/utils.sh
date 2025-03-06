#!/usr/bin/env bash
# Setupr Utility Functions
# This file contains common utility functions used across the Setupr scripts.
# Author: ByteTrix
# License: MIT

set -euo pipefail

# Color definitions for logging
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
#######################################

# Log an informational message
# Args:
#   $1 - Message to log
log_info() {
    printf "${BLUE}[INFO]${NC} %s - %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

# Log a warning message
# Args:
#   $1 - Message to log
log_warn() {
    printf "${YELLOW}[WARN]${NC} %s - %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

# Log an error message
# Args:
#   $1 - Message to log
log_error() {
    printf "${RED}[ERROR]${NC} %s - %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

# Log a success message
# Args:
#   $1 - Message to log
log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s - %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

# Sudo management functions
#######################################

# Initialize a sudo session with extended timeout
# This function sets up a background process to keep the sudo token alive
init_sudo_session() {
    # Return early if already in sudo context
    if [ -n "${SUDO_USER:-}" ]; then
        return 0
    fi
    
    log_info "Initializing sudo session..."
    
    # Use a longer timeout for sudo (4 hours)
    if ! sudo -v -p "Please enter your password: "; then
        log_error "Failed to initialize sudo session"
        return 1
    fi
    
    # Refresh sudo token every 10 minutes
    (while true; do
        sudo -n true
        sleep 600
    done) 2>/dev/null &
    
    SUDO_KEEPER_PID=$!
    
    # Clean up the background process on exit
    trap 'kill $SUDO_KEEPER_PID 2>/dev/null || true' EXIT
}

# Execute command with sudo if needed
# Args:
#   $@ - Command and arguments to execute
sudo_exec() {
    if [ $# -eq 0 ]; then
        log_error "sudo_exec: No command provided"
        return 1
    fi

    if [ -n "${SUDO_USER:-}" ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Check if running in sudo context
# Returns:
#   0 if in sudo context, 1 otherwise
is_sudo_context() {
    [ -n "${SUDO_USER:-}" ]
}

# Check for apt/dpkg locks and wait if needed
# Returns:
#   0 if locks are cleared, 1 if timeout reached
wait_for_apt_locks() {
    local timeout=300  # 5 minutes timeout
    local start_time=$(date +%s)

    while true; do
        if ! fuser /var/lib/dpkg/lock >/dev/null 2>&1 && \
           ! fuser /var/lib/apt/lists/lock >/dev/null 2>&1 && \
           ! fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then
            return 0
        fi

        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -ge $timeout ]; then
            log_error "Timeout waiting for apt/dpkg locks to be released"
            return 1
        fi

        log_warn "Another package manager process is running. Waiting..."
        sleep 5
    done
}

# File management functions
#######################################

# Create a backup of a file with timestamp
# Args:
#   $1 - Path to file to backup
backup_file() {
    local file="$1"
    
    if [ -z "$file" ]; then
        log_error "backup_file: No file specified"
        return 1
    fi

    if [ -e "$file" ] || [ -L "$file" ]; then
        local backup="${file}.backup.$(date +%s)"
        if mv "$file" "$backup"; then
            log_info "Backed up $file to $backup"
        else
            log_error "Failed to backup $file"
            return 1
        fi
    fi
}

# Create a symbolic link with backup of existing target
# Args:
#   $1 - Source file path
#   $2 - Target file path
symlink_file() {
    local source_file="$1"
    local target_file="$2"
    
    if [ -z "$source_file" ] || [ -z "$target_file" ]; then
        log_error "symlink_file: Source and target files must be specified"
        return 1
    fi

    if ! [ -e "$source_file" ]; then
        log_error "symlink_file: Source file does not exist: $source_file"
        return 1
    fi

    backup_file "$target_file"
    if ln -sf "$source_file" "$target_file"; then
        log_info "Created symlink: $source_file -> $target_file"
    else
        log_error "Failed to create symlink: $source_file -> $target_file"
        return 1
    fi
}

# Configuration management functions
#######################################

# Load JSON configuration from file
# Args:
#   $1 - Path to config file
load_config() {
    local config_file="$1"
    
    if [ -z "$config_file" ]; then
        log_error "load_config: No config file specified"
        return 1
    fi

    if [ -f "$config_file" ]; then
        if ! jq -r '.' "$config_file" 2>/dev/null; then
            log_error "Failed to parse config file: $config_file"
            return 1
        fi
    else
        log_error "Config file not found: $config_file"
        return 1
    fi
}

# Save JSON configuration to file
# Args:
#   $1 - Path to config file
#   $2 - JSON configuration data
save_config() {
    local config_file="$1"
    local config_data="$2"
    
    if [ -z "$config_file" ] || [ -z "$config_data" ]; then
        log_error "save_config: Config file and data must be specified"
        return 1
    fi

    if ! echo "$config_data" | jq '.' > "$config_file" 2>/dev/null; then
        log_error "Failed to save config to: $config_file"
        return 1
    fi
    log_success "Saved config to $config_file"
}

# Display installation summary from config
# Args:
#   $1 - Path to config file
display_summary() {
    local config_file="$1"
    
    if [ -z "$config_file" ]; then
        log_error "display_summary: No config file specified"
        return 1
    fi

    echo -e "\nInstallation Summary"
    echo "==================="
    
    if [ -f "$config_file" ]; then
        if ! jq -e . "$config_file" >/dev/null 2>&1; then
            log_error "Invalid JSON in config file: $config_file"
            return 1
        fi

        local mode timestamp
        mode=$(jq -r '.mode // "N/A"' "$config_file")
        timestamp=$(jq -r '.timestamp // "N/A"' "$config_file")
        
        echo "Mode: $mode"
        echo "Time: $timestamp"
        echo -e "\nSelected Packages:"
        
        if jq -e '.packages' "$config_file" >/dev/null 2>&1; then
            jq -r '.packages[]' "$config_file" | while read -r package; do
                echo "  • $package"
            done
        else
            echo "  No packages selected"
        fi
    else
        log_warn "No configuration found at: $config_file"
    fi
    echo
}
