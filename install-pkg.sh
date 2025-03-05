#!/usr/bin/env bash

# Source utility functions
source "$(dirname "$0")/lib/utils.sh"

set -euo pipefail

# Function to detect package manager
get_package_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    else
        return 1
    fi
}

# Function to clean repository files
clean_repository() {
    local name="$1"
    
    # Remove old repository files
    sudo rm -f "/etc/apt/sources.list.d/${name}.list"
    sudo rm -f "/etc/apt/sources.list.d/${name}-*.list"
    sudo rm -f "/etc/apt/trusted.gpg.d/${name}*.gpg"
    sudo rm -f "/usr/share/keyrings/${name}*.gpg"
}

# Function to add repository GPG key
add_repository_key() {
    local name="$1"
    local key_url="$2"
    local keyring="/usr/share/keyrings/${name}.gpg"
    
    curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring"
    echo "$keyring"
}

# Function to setup package sources
setup_package_source() {
    local pkg="$1"
    
    case "$pkg" in
        "google-chrome-stable")
            clean_repository "google-chrome"
            local keyring
            keyring=$(add_repository_key "google-chrome" "https://dl.google.com/linux/linux_signing_key.pub")
            echo "deb [arch=amd64 signed-by=$keyring] http://dl.google.com/linux/chrome/deb/ stable main" | \
                sudo tee /etc/apt/sources.list.d/google-chrome.list
            ;;
        "code"|"vscode")
            clean_repository "vscode"
            local keyring
            keyring=$(add_repository_key "vscode" "https://packages.microsoft.com/keys/microsoft.asc")
            echo "deb [arch=amd64,arm64,armhf signed-by=$keyring] https://packages.microsoft.com/repos/code stable main" | \
                sudo tee /etc/apt/sources.list.d/vscode.list
            ;;
        "brave-browser")
            clean_repository "brave-browser"
            local keyring
            keyring=$(add_repository_key "brave-browser" "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg")
            echo "deb [arch=amd64 signed-by=$keyring] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
                sudo tee /etc/apt/sources.list.d/brave-browser.list
            ;;
        "sublime-text")
            clean_repository "sublime-text"
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
            echo "deb https://download.sublimetext.com/ apt/stable/" | \
                sudo tee /etc/apt/sources.list.d/sublime-text.list
            ;;
        "nodejs"|"npm")
            clean_repository "nodesource"
            local keyring
            keyring=$(add_repository_key "nodesource" "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key")
            echo "deb [signed-by=$keyring] https://deb.nodesource.com/node_20.x nodistro main" | \
                sudo tee /etc/apt/sources.list.d/nodesource.list
            ;;
    esac
    
    # Update package lists if we added a new source
    if [ $? -eq 0 ]; then
        sudo apt update
    fi
}

# Function to ensure snap is installed
ensure_snap() {
    if ! command -v snap &>/dev/null; then
        log_info "Installing snap support..."
        sudo apt update
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        # Wait for snap to be ready
        sleep 5
    fi
}

# Function to install a package using apt
install_apt_package() {
    local pkg="$1"
    local retries=3
    local attempt=1
    
    # Setup package source if needed
    setup_package_source "$pkg"
    
    while [ $attempt -le $retries ]; do
        log_info "Attempt $attempt of $retries: Installing $pkg"
        if sudo DEBIAN_FRONTEND=noninteractive apt install -y "$pkg"; then
            return 0
        fi
        ((attempt++))
        sleep 2
    done
    
    return 1
}

# Function to install a package using snap
install_snap_package() {
    local pkg="$1"
    local retries=3
    local attempt=1
    
    # Some snaps require classic confinement
    local classic_snaps="code vscode android-studio intellij-idea-community pycharm-community postman gitkraken"
    
    while [ $attempt -le $retries ]; do
        log_info "Attempt $attempt of $retries: Installing $pkg"
        if echo "$classic_snaps" | grep -q -w "$pkg"; then
            if sudo snap install "$pkg" --classic; then
                return 0
            fi
        else
            if sudo snap install "$pkg"; then
                return 0
            fi
        fi
        ((attempt++))
        sleep 2
    done
    
    return 1
}

# Function to install a specific package with its type
install_package() {
    local pkg_with_type="$1"
    local pkg_name="${pkg_with_type%:*}"
    local pkg_type="${pkg_with_type#*:}"
    
    log_info "Installing $pkg_name using $pkg_type..."
    
    case "$pkg_type" in
        "apt")
            install_apt_package "$pkg_name"
            ;;
        "snap")
            ensure_snap
            install_snap_package "$pkg_name"
            ;;
        "vscode")
            # Special case for VS Code
            if command -v snap &>/dev/null; then
                install_snap_package "code"
            else
                setup_package_source "code"
                install_apt_package "code"
            fi
            ;;
        *)
            log_error "Unsupported package type: $pkg_type"
            return 1
            ;;
    esac
}

# Main execution

# Initialize sudo session
init_sudo_session

# Update package lists
sudo apt update

# Read packages from stdin and install them
failed_packages=()

while IFS= read -r package || [ -n "$package" ]; do
    if [ -z "$package" ]; then
        continue
    fi

    if ! install_package "$package"; then
        failed_packages+=("$package")
    fi
done

# Report results
if [ ${#failed_packages[@]} -eq 0 ]; then
    log_success "All packages installed successfully"
else
    log_error "Failed to install the following packages:"
    printf '%s\n' "${failed_packages[@]}"
    exit 1
fi