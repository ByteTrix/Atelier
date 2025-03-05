#!/usr/bin/env bash
#
# Package Installation Template
# ---------------------------
# Professional template for Setupr installation scriptson scripts.
# with streamlined installation methods and error handling.endency checking, and configuration management.
#
# Author: ByteTrixes:
# License: MIT

 - Progress tracking
# Package Information (customize these variables)erification
PACKAGE_NAME="app-name"              # Package name (for apt, snap, etc.)
PACKAGE_LABEL="Application Name"     # User-friendly application name# Usage:
PACKAGE_BIN="command-name"           # Binary name to check installationtemplate to create a new module
PACKAGE_CATEGORY="apps"              # Category folder name#   2. Replace MODULE_NAME and PACKAGE_NAME variables
check_dependencies and install_package functions
# Source utilities
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if package is already installed
is_installed() {
    # Check common installation methods
    if command -v "$PACKAGE_BIN" &>/dev/null || \
       [ -f "/usr/share/applications/${PACKAGE_NAME}.desktop" ] || \Replace with actual module name
       [ -f "$HOME/.local/share/applications/${PACKAGE_NAME}.desktop" ] || \readonly PACKAGE_NAME="package-name"   # Replace with actual package name
       (command -v snap &>/dev/null && snap list 2>/dev/null | grep -q "$PACKAGE_NAME") || \es
       (command -v flatpak &>/dev/null && flatpak list 2>/dev/null | grep -q "$PACKAGE_NAME")
    then
        return 0  # Found installed
    fi_DIR}/../../lib/utils.sh"
    
    return 1  # Not installeditialize sudo session at the start
}

# Install via APT (primary method)mand exists
install_via_apt() {d_exists() {
    log_info "[$PACKAGE_CATEGORY] Installing $PACKAGE_LABEL via APT..."command -v "$1" >/dev/null 2>&1
    
    # Add repository if needed (uncomment and modify if required)
    # sudo_exec add-apt-repository -y ppa:repository-name/ppaired dependencies
    dependencies() {
    sudo_exec apt-get update -qqlocal missing_deps=()
    if sudo_exec apt-get install -y "$PACKAGE_NAME"; then
        log_success "[$PACKAGE_CATEGORY] $PACKAGE_LABEL installed successfully via APT"
        return 0
    fideps+=("$cmd")
    
    log_error "[$PACKAGE_CATEGORY] Failed to install $PACKAGE_LABEL via APT"
    return 1
}@]} -ne 0 ]; then

# Install via Snap (alternative method)
install_via_snap() {
    log_info "[$PACKAGE_CATEGORY] Installing $PACKAGE_LABEL via Snap..."
    
    # Install snapd if not available
    if ! command -v snap &>/dev/null; then
        log_info "[$PACKAGE_CATEGORY] Installing snapd..."
        if ! sudo_exec apt-get install -y snapd; thenibility() {
            log_error "[$PACKAGE_CATEGORY] Failed to install snapd"
            return 1if ! command_exists "apt-get"; then
        fi requires an Ubuntu-based system"
    fi
    fi
    # Install the snap package
    if sudo_exec snap install "$PACKAGE_NAME"; then
        log_success "[$PACKAGE_CATEGORY] $PACKAGE_LABEL installed successfully via Snap"
        return 0encies
    fidependencies() {
    
    log_error "[$PACKAGE_CATEGORY] Failed to install $PACKAGE_LABEL via Snap"
    return 1Update package index (using sudo_exec to avoid password prompt)
}   sudo_exec apt-get update
    
# Install via direct download (DEB method)cy installation commands here
install_via_deb() {
    local DEB_URL="https://example.com/path/to/${PACKAGE_NAME}.deb"  # Replace with actual URL
    local DEB_FILE="/tmp/${PACKAGE_NAME}.deb"#     log_error "Failed to install dependencies"
    
    log_info "[$PACKAGE_CATEGORY] Installing $PACKAGE_LABEL via DEB package..."
    
    # Download the DEB package
    if ! curl -sSL "$DEB_URL" -o "$DEB_FILE"; then
        log_error "[$PACKAGE_CATEGORY] Failed to download $PACKAGE_LABEL DEB package"
        return 1all the package
    fiall_package() {
    
    # Install gdebi if not available
    if ! command -v gdebi &>/dev/null; thenlation steps here
        sudo_exec apt-get install -y gdebi-coreample:
    fi
    ror "Failed to install $PACKAGE_NAME"
    # Install the DEB package    return 1
    if sudo_exec gdebi -n "$DEB_FILE"; then   # fi
        rm -f "$DEB_FILE"    
        log_success "[$PACKAGE_CATEGORY] $PACKAGE_LABEL installed successfully via DEB"
        return 0
    fi
    nfigure the installed package
    rm -f "$DEB_FILE"
    log_error "[$PACKAGE_CATEGORY] Failed to install $PACKAGE_LABEL via DEB"log_info "Configuring $MODULE_NAME..."
    return 1
}

# Create desktop entry (only if needed)
create_desktop_entry() {ig_file" ]; then
    # Skip if desktop entry already existsbackup_file "$config_file"
    if [ -f "/usr/share/applications/${PACKAGE_NAME}.desktop" ] || [ -f "$HOME/.local/share/applications/${PACKAGE_NAME}.desktop" ]; then  if ! sudo_exec cp "./config/default.conf" "$config_file"; then
        log_info "[$PACKAGE_CATEGORY] Desktop entry for $PACKAGE_LABEL already exists"
        return 0
    fi
    
    log_info "[$PACKAGE_CATEGORY] Creating desktop entry for $PACKAGE_LABEL..."
    return 0
    # Create local applications directory if it doesn't exist
    mkdir -p "$HOME/.local/share/applications"
    tallation
    # Create desktop entry filenstallation() {
    cat > "$HOME/.local/share/applications/${PACKAGE_NAME}.desktop" << EOF
[Desktop Entry]
Name=$PACKAGE_LABEL ! command_exists "$PACKAGE_NAME"; then
Exec=$PACKAGE_BIN       log_error "$MODULE_NAME installation verification failed"
Type=Application        return 1
Terminal=false
Categories=Utility;
Comment=$PACKAGE_LABEL
EOF
    # if ! sudo_exec systemctl is-active --quiet service-name; then
    # Add icon if available (modify path as needed)
    if [ -f "/opt/${PACKAGE_NAME}/icon.png" ]; then#     return 1
        echo "Icon=/opt/${PACKAGE_NAME}/icon.png" >> "$HOME/.local/share/applications/${PACKAGE_NAME}.desktop"
    fi
    
    chmod +x "$HOME/.local/share/applications/${PACKAGE_NAME}.desktop"
    log_success "[$PACKAGE_CATEGORY] Desktop entry created for $PACKAGE_LABEL"
    return 0 installation function
}() {
E_NAME installation..."
# Optional: Configure application settings
configure_application() {
    local CONFIG_DIR="$HOME/.config/$PACKAGE_NAME"if command_exists "$PACKAGE_NAME"; then
    E is already installed"
    # Skip if already configured
    if [ -d "$CONFIG_DIR" ] && [ -f "$CONFIG_DIR/config.json" ]; then
        log_info "[$PACKAGE_CATEGORY] $PACKAGE_LABEL is already configured"
        return 0em compatibility
    fi check_system_compatibility; then
    
    log_info "[$PACKAGE_CATEGORY] Configuring $PACKAGE_LABEL..."
    
    # Create config directory
    mkdir -p "$CONFIG_DIR"   # Check dependencies
        if ! check_dependencies; then
    # Example: Copy default config if availablency check failed"
    # if [ -f "${SCRIPT_DIR}/config/${PACKAGE_NAME}.json" ]; then
    #     cp "${SCRIPT_DIR}/config/${PACKAGE_NAME}.json" "$CONFIG_DIR/config.json"
    # fi
    
    # Example: Set permissionsif ! install_dependencies; then
    chmod 700 "$CONFIG_DIR"
        exit 1
    log_success "[$PACKAGE_CATEGORY] $PACKAGE_LABEL configured successfully"
    return 0
}

# Verify installationr "Installation failed"
verify_installation() {  exit 1
    log_info "[$PACKAGE_CATEGORY] Verifying $PACKAGE_LABEL installation..."fi
    
    # Check if installed
    if is_installed; thenif ! configure_package; then
        log_success "[$PACKAGE_CATEGORY] $PACKAGE_LABEL installed successfully"figuration had some issues, but continuing..."
        return 0
    fi
    
    log_error "[$PACKAGE_CATEGORY] $PACKAGE_LABEL installation verification failed"n
    return 1nstallation verification failed"
}it 1

# Main installation function
main() {
    log_info "[$PACKAGE_CATEGORY] Starting installation of $PACKAGE_LABEL..."
    
    # Check if already installed
    if is_installed; then        log_warn "[$PACKAGE_CATEGORY] $PACKAGE_LABEL is already installed"        return 0    fi        # APT Installation (primary method)    install_via_apt && verify_installation && return 0        # Snap Installation (fallback method)    log_info "[$PACKAGE_CATEGORY] APT installation failed, trying Snap..."    install_via_snap && verify_installation && return 0        # DEB Installation (fallback method)    # Uncomment if needed    # log_info "[$PACKAGE_CATEGORY] Snap installation failed, trying DEB..."    # install_via_deb && verify_installation && return 0        # Create desktop entry if needed    # Uncomment if needed    # create_desktop_entry        # Configure application    # Uncomment if needed    # configure_application        # If we get here, all installation methods failed    log_error "[$PACKAGE_CATEGORY] Failed to install $PACKAGE_LABEL by any method"    return 1}# Run the main functionmain "$@"