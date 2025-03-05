#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if VS Code is already installed
if command -v code &>/dev/null; then
    log_warn "[vscode] Visual Studio Code is already installed"
    code --version
    return 0
fi

log_info "[vscode] Installing Visual Studio Code..."

# Create keyrings directory
sudo_exec mkdir -p /etc/apt/keyrings

# Configure Microsoft repository
log_info "[vscode] Configuring Microsoft repository..."
if ! echo "code code/add-microsoft-repo boolean true" | sudo_exec debconf-set-selections; then
    log_error "[vscode] Failed to configure Microsoft repository"
    return 1
fi

# Create temp directory for downloads
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || {
    log_error "[vscode] Failed to create temporary directory"
    return 1
}

# Download and install the Microsoft GPG key
log_info "[vscode] Adding Microsoft GPG key..."
if ! wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo_exec gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg; then
    log_error "[vscode] Failed to download or import Microsoft GPG key"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Add the VS Code repository
log_info "[vscode] Adding VS Code repository..."
if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo_exec tee /etc/apt/sources.list.d/vscode.list > /dev/null; then
    log_error "[vscode] Failed to add VS Code repository"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Update package lists
log_info "[vscode] Updating package lists..."
if ! sudo_exec apt-get update; then
    log_error "[vscode] Failed to update package lists"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Install VS Code
log_info "[vscode] Installing VS Code..."
if ! sudo_exec apt-get install -y code; then
    log_error "[vscode] Failed to install VS Code"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Clean up
cd - &>/dev/null || true
rm -rf "$TEMP_DIR"

# Verify installation
if command -v code &>/dev/null; then
    log_success "[vscode] Visual Studio Code installed successfully"
    code --version
    
    # Display help info
    log_info "[vscode] Quick start guide:"
    echo "
    - Launch: code
    - Open folder: code /path/to/folder
    - Open Command Palette: Ctrl+Shift+P
    - Install Extensions: View -> Extensions (Ctrl+Shift+X)
    - Settings: File -> Preferences -> Settings (Ctrl+,)
    "
    return 0
else
    log_error "[vscode] VS Code installation could not be verified"
    return 1
fi
