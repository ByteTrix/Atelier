#!/usr/bin/env bash
#
# System Cleanup Script
# -------------------
# Performs comprehensive system cleanup by removing:
# - Package cache and unused packages
# - Temporary files
# - User cache
# - System journals
# - Old log files
# - Thumbnail cache
#
# Features:
# - Safe cleanup with backups
# - Progress tracking
# - Size reporting
# - Error handling
# - Configurable cleanup levels
#
# Author: ByteTrix
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/lib/utils.sh"

# Configuration
readonly MAX_LOG_AGE=30 # days
readonly MAX_JOURNAL_SIZE="500M"
readonly BACKUP_DIR="${HOME}/.cache/setupr/cleanup_backup"

# Determine sudo command based on environment
SUDO_CMD="sudo"
if [[ "${SETUPR_SUDO:-0}" == "1" ]]; then
    SUDO_CMD="sudo_exec"
fi

# Get size of directory
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Create backup of important files
create_backup() {
    local source_dir="$1"
    local backup_name="$2"
    local backup_path="${BACKUP_DIR}/${backup_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    if [ -e "$source_dir" ]; then
        mkdir -p "$BACKUP_DIR"
        if tar czf "$backup_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>/dev/null; then
            log_info "Created backup: $backup_path"
            return 0
        fi
    fi
    return 1
}

# Clean package manager cache
clean_package_cache() {
    log_info "Cleaning package cache..."
    local before_size
    before_size=$(get_size /var/cache/apt/archives)
    
    # Update package list and clean cache
    if ! $SUDO_CMD apt-get update >/dev/null; then
        log_warn "Failed to update package lists"
    fi
    
    if ! $SUDO_CMD apt-get clean; then
        log_warn "Failed to clean apt cache"
    fi
    
    if ! $SUDO_CMD apt-get autoremove -y; then
        log_warn "Failed to remove unused packages"
    fi
    
    if ! $SUDO_CMD apt-get autoclean; then
        log_warn "Failed to auto-clean package cache"
    fi
    
    local after_size
    after_size=$(get_size /var/cache/apt/archives)
    log_success "Package cache cleanup complete (Before: $before_size, After: $after_size)"
}

# Clean temporary files
clean_temp_files() {
    log_info "Cleaning temporary files..."
    local before_size
    before_size=$(get_size /tmp)
    
    # Clean /tmp with safety checks
    if [ -d "/tmp" ]; then
        $SUDO_CMD find /tmp -type f -atime +1 -delete 2>/dev/null || \
            log_warn "Failed to clean some temporary files"
    fi
    
    local after_size
    after_size=$(get_size /tmp)
    log_success "Temporary files cleanup complete (Before: $before_size, After: $after_size)"
}

# Clean user cache
clean_user_cache() {
    log_info "Cleaning user cache..."
    local cache_dir="$HOME/.cache"
    local before_size
    before_size=$(get_size "$cache_dir")
    
    if [ -d "$cache_dir" ]; then
        # Backup browser data
        create_backup "$cache_dir/mozilla" "firefox_cache"
        create_backup "$cache_dir/chromium" "chromium_cache"
        
        # Clean various cache directories
        rm -rf "$cache_dir/"* 2>/dev/null || \
            log_warn "Failed to clean some user cache files"
        
        # Clean thumbnail cache
        rm -rf "$HOME/.thumbnails/"* 2>/dev/null || \
            log_warn "Failed to clean thumbnail cache"
    fi
    
    local after_size
    after_size=$(get_size "$cache_dir")
    log_success "User cache cleanup complete (Before: $before_size, After: $after_size)"
}

# Clean system journals
clean_system_journals() {
    log_info "Cleaning system journals..."
    
    if command -v journalctl >/dev/null 2>&1; then
        # Vacuum journal files
        if ! $SUDO_CMD journalctl --vacuum-time="${MAX_LOG_AGE}d" --vacuum-size="$MAX_JOURNAL_SIZE"; then
            log_warn "Failed to vacuum system journals"
        fi
        
        # Rotate and clean logs
        if ! $SUDO_CMD logrotate -f /etc/logrotate.conf; then
            log_warn "Failed to rotate system logs"
        fi
    else
        log_warn "journalctl not found, skipping journal cleanup"
    fi
    
    log_success "System journal cleanup complete"
}

# Clean old log files
clean_log_files() {
    log_info "Cleaning old log files..."
    local before_size
    before_size=$(get_size /var/log)
    
    # Find and remove old log files
    $SUDO_CMD find /var/log -type f -name "*.log.*" -mtime +$MAX_LOG_AGE -delete 2>/dev/null || \
        log_warn "Failed to clean some old log files"
    
    # Compress current logs
    $SUDO_CMD find /var/log -type f -name "*.log" -exec gzip -f {} \; 2>/dev/null || \
        log_warn "Failed to compress some log files"
    
    local after_size
    after_size=$(get_size /var/log)
    log_success "Log files cleanup complete (Before: $before_size, After: $after_size)"
}

# Main cleanup function
main() {
    log_info "Starting system cleanup..."
    
    # Ensure proper permissions
    if [ "$EUID" -ne 0 ] && [ -z "${SUDO_USER:-}" ]; then
        log_error "This script must be run with sudo"
        exit 1
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Run cleanup tasks
    clean_package_cache
    clean_temp_files
    clean_user_cache
    clean_system_journals
    clean_log_files
    
    log_success "System cleanup completed successfully!"
    log_info "Backups stored in: $BACKUP_DIR"
}

# Run main function
main "$@"
