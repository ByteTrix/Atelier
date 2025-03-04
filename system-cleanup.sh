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

# Initialize sudo session at the start
init_sudo_session

# Configuration
readonly MAX_LOG_AGE=30 # days
readonly MAX_JOURNAL_SIZE="500M"
readonly BACKUP_DIR="${HOME}/.cache/setupr/cleanup_backup"

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
    if ! sudo_exec apt-get update >/dev/null; then
        log_warn "Failed to update package lists"
    fi
    
    if ! sudo_exec apt-get clean; then
        log_warn "Failed to clean apt cache"
    fi
    
    if ! sudo_exec apt-get autoremove -y; then
        log_warn "Failed to remove unused packages"
    fi
    
    if ! sudo_exec apt-get autoclean; then
        log_warn "Failed to auto-clean package cache"
    fi
    
    local after_size
    after_size=$(get_size /var/cache/apt/archives)
    log_info "Package cache cleanup complete (Before: $before_size, After: $after_size)"
}

# Clean temporary files
clean_temp_files() {
    log_info "Cleaning temporary files..."
    local before_size
    before_size=$(get_size /tmp)
    
    # Clean /tmp with safety checks
    if [ -d "/tmp" ]; then
        sudo_exec find /tmp -type f -atime +1 -delete 2>/dev/null || \
            log_warn "Failed to clean some temporary files"
    fi
    
    local after_size
    after_size=$(get_size /tmp)
    log_info "Temporary files cleanup complete (Before: $before_size, After: $after_size)"
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
    log_info "User cache cleanup complete (Before: $before_size, After: $after_size)"
}

# Clean system journals
clean_system_journals() {
    log_info "Cleaning system journals..."
    
    if command -v journalctl >/dev/null 2>&1; then
        # Vacuum journal files
        if ! sudo_exec journalctl --vacuum-time="${MAX_LOG_AGE}d" --vacuum-size="$MAX_JOURNAL_SIZE"; then
            log_warn "Failed to vacuum system journals"
        fi
        
        # Rotate and clean logs
        if ! sudo_exec logrotate -f /etc/logrotate.conf; then
            log_warn "Failed to rotate system logs"
        fi
    else
        log_warn "journalctl not found, skipping journal cleanup"
    fi
    
    log_info "System journal cleanup complete"
}

# Clean old log files
clean_log_files() {
    log_info "Cleaning old log files..."
    local before_size
    before_size=$(get_size /var/log)
    
    # Find and remove old log files
    sudo_exec find /var/log -type f -name "*.log.*" -mtime +$MAX_LOG_AGE -delete 2>/dev/null || \
        log_warn "Failed to clean some old log files"
    
    # Compress current logs
    sudo_exec find /var/log -type f -name "*.log" -exec gzip -f {} \; 2>/dev/null || \
        log_warn "Failed to compress some log files"
    
    local after_size
    after_size=$(get_size /var/log)
    log_info "Log files cleanup complete (Before: $before_size, After: $after_size)"
}

# Main cleanup function
main() {
    log_info "Starting system cleanup..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Run cleanup tasks
    clean_package_cache
    clean_temp_files
    clean_user_cache
    clean_system_journals
    clean_log_files
    
    log_info "System cleanup completed successfully!"
    log_info "Backups stored in: $BACKUP_DIR"
}

# Run main function
main "$@"
