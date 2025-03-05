#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Localsend is already installed
if command -v localsend &>/dev/null || snap list localsend &>/dev/null; then
    log_warn "[apps] Localsend is already installed"
    snap list localsend 2>/dev/null || which localsend
    return 0
fi

log_info "[apps] Installing Localsend..."

# Try snap installation first
if command -v snap &>/dev/null; then
    log_info "[apps] Attempting installation via snap..."
    if snap install localsend; then
        if snap list localsend &>/dev/null; then
            log_success "[apps] Localsend installed successfully via snap"
            snap list localsend
            return 0
        fi
    fi
fi

# Fallback to apt installation
log_info "[apps] Attempting installation via apt..."
if ! sudo add-apt-repository -y ppa:localsend/ppa; then
    log_error "[apps] Failed to add Localsend repository"
    return 1
fi

if ! sudo apt-get update; then
    log_error "[apps] Failed to update package lists"
    return 1
fi

if ! sudo apt-get install -y localsend; then
    log_error "[apps] Failed to install Localsend via apt"
    return 1
fi

# Verify installation
if command -v localsend &>/dev/null; then
    log_success "[apps] Localsend installed successfully via apt"
    which localsend
    return 0
else
    log_error "[apps] Localsend installation failed"
    return 1
fi
