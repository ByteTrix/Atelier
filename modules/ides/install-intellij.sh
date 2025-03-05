#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if IntelliJ is already installed
if snap list intellij-idea-community &>/dev/null; then
    log_warn "[ides] IntelliJ IDEA is already installed"
    snap list intellij-idea-community
    return 0
fi

log_info "[ides] Installing IntelliJ IDEA Community Edition..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "[ides] Snap is not installed. Please install snapd first."
    return 1
fi

# Install IntelliJ IDEA
log_info "[ides] Installing IntelliJ IDEA via Snap..."
if ! snap install intellij-idea-community --classic; then
    log_error "[ides] Failed to install IntelliJ IDEA"
    return 1
fi

# Verify installation
if snap list intellij-idea-community &>/dev/null; then
    log_success "[ides] IntelliJ IDEA installed successfully"
    snap list intellij-idea-community
    
    # Display help information
    log_info "[ides] Quick start guide:"
    echo "
    - Launch: intellij-idea-community
    - First run will require initial setup
    - Configure JDK in File -> Project Structure
    - Import settings from previous installation if available
    - Popular plugins to consider:
      * Rainbow Brackets
      * Key Promoter X
      * GitToolBox
      * Lombok
    "
    return 0
else
    log_error "[ides] IntelliJ IDEA installation could not be verified"
    return 1
fi
