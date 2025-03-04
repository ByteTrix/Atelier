#!/usr/bin/env bash
set -euo pipefail

# Improved sudo session management
init_sudo_session() {
    # Return early if already in sudo context
    if [ -n "${SUDO_USER:-}" ]; then
        return 0
    fi
    
    log_info "Initializing sudo session..."
    
    # Use a longer timeout for sudo (4 hours)
    sudo -v -p "Please enter your password: "
    
    # Only refresh sudo token every 10 minutes instead of 50 seconds
    # This reduces the number of potential askpass prompts
    (while true; do
        sudo -n true
        sleep 600
    done) 2>/dev/null &
    
    # Store the background process ID
    SUDO_KEEPER_PID=$!
    
    # Clean up the background process on exit
    trap 'kill $SUDO_KEEPER_PID 2>/dev/null || true' EXIT
}

# Execute command with sudo if needed
sudo_exec() {
    if [ -n "${SUDO_USER:-}" ]; then
        # Already in sudo context, execute directly
        "$@"
    else
        # Not in sudo context, use sudo
        sudo "$@"
    fi
}

# Check if running with sudo
is_sudo_context() {
    [ -n "${SUDO_USER:-}" ]
}

log_info() {
  echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_warn() {
  echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_error() {
  echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

backup_file() {
  local file="$1"
  if [ -e "$file" ] || [ -L "$file" ]; then
    mv "$file" "${file}.backup.$(date +%s)"
    log_info "Backed up $file"
  fi
}

symlink_file() {
  local source_file="$1"
  local target_file="$2"
  backup_file "$target_file"
  ln -sf "$source_file" "$target_file"
  log_info "Linked $source_file -> $target_file"
}

# Config management functions
load_config() {
  local config_file="$1"
  if [ -f "$config_file" ]; then
    jq -r '.' "$config_file"
  fi
}

save_config() {
  local config_file="$1"
  local config_data="$2"
  echo "$config_data" | jq '.' > "$config_file"
  log_info "Saved config to $config_file"
}

# Function to display installation summary
display_summary() {
  local config_file="$1"
  
  echo "Installation Summary"
  echo "==================="
  if [ -f "$config_file" ]; then
    local mode timestamp packages
    
    mode=$(jq -r '.mode' "$config_file")
    timestamp=$(jq -r '.timestamp' "$config_file")
    
    echo "Mode: $mode"
    echo "Time: $timestamp"
    echo -e "\nSelected Packages:"
    
    jq -r '.packages[]' "$config_file" | while read -r package; do
      echo "  • $package"
    done
  else
    echo "No configuration found."
  fi
  echo
}
