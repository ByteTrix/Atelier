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

# Function to clean system repositories
clean_system_repositories() {
    # Backup existing repo lists
    sudo mkdir -p /etc/apt/sources.list.d/backup
    
    # Move existing files to backup
    sudo mv /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/backup/ 2>/dev/null || true
    
    # Wait for any existing package operations
    if ! wait_for_apt_locks; then
        log_error "Package manager is busy and timed out waiting"
        sudo mv /etc/apt/sources.list.d/backup/*.list /etc/apt/sources.list.d/ 2>/dev/null || true
        return 1
    fi
    
    # Update package lists with only main sources
    if ! sudo apt-get update -o Dir::Etc::sourcelist="/etc/apt/sources.list" \
        -o Dir::Etc::sourceparts="-" \
        -o APT::Get::List-Cleanup="0"; then
        log_error "Failed to update package lists, restoring backups..."
        sudo mv /etc/apt/sources.list.d/backup/*.list /etc/apt/sources.list.d/ 2>/dev/null || true
        return 1
    fi
}

# Function to setup repository
setup_repository() {
    local name="$1"
    local key_url="$2"
    local repo_url="$3"
    local repo_line="$4"
    local list_path="/etc/apt/sources.list.d/${name}.list"
    
    # Download and add GPG key
    if ! curl -fsSL "$key_url" | sudo apt-key add -; then
        log_error "Failed to add GPG key from $key_url"
        return 1
    fi
    
    # Add repository
    if ! echo "deb [arch=amd64] $repo_url $repo_line" | \
        sudo tee "$list_path" >/dev/null; then
        log_error "Failed to add repository to $list_path"
        return 1
    fi
    
    # Wait for any existing package operations
    if ! wait_for_apt_locks; then
        log_error "Package manager is busy and timed out waiting"
        return 1
    fi

    # Update only this repository
    if ! sudo apt-get update -o Dir::Etc::sourcelist="$list_path" \
        -o Dir::Etc::sourceparts="-" \
        -o APT::Get::List-Cleanup="0"; then
        log_error "Failed to update package lists for $name repository"
        return 1
    fi
    
    log_success "Successfully configured $name repository"
    return 0
}

# Function to setup package sources
setup_package_source() {
    local pkg="$1"
    
    case "$pkg" in
        "google-chrome-stable")
            setup_repository \
                "google-chrome" \
                "https://dl.google.com/linux/linux_signing_key.pub" \
                "http://dl.google.com/linux/chrome/deb/" \
                "stable main"
            ;;
        "code"|"vscode")
            setup_repository \
                "vscode" \
                "https://packages.microsoft.com/keys/microsoft.asc" \
                "https://packages.microsoft.com/repos/code" \
                "stable main"
            ;;
        "brave-browser")
            setup_repository \
                "brave-browser" \
                "https://brave-browser-apt-release.s3.brave.com/brave-core.asc" \
                "https://brave-browser-apt-release.s3.brave.com/" \
                "stable main"
            ;;
        "nodejs"|"npm")
            setup_repository \
                "nodesource" \
                "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
                "https://deb.nodesource.com/node_20.x" \
                "nodistro main"
            ;;
    esac
}

# Function to ensure snap is installed
ensure_snap() {
    if ! command -v snap &>/dev/null; then
        log_info "Installing snap support..."
        sudo apt-get install -y snapd
        sudo systemctl enable --now snapd.socket
        sleep 5
    fi
}

# Function to install a package using apt
install_apt_package() {
    local pkg="$1"
    local retries=3
    local attempt=1
    
    setup_package_source "$pkg"
    
    while [ $attempt -le $retries ]; do
        log_info "Attempt $attempt of $retries: Installing $pkg"
        
        if ! wait_for_apt_locks; then
            log_error "Package manager is busy and timed out waiting"
            return 1
        fi
        
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"; then
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

# Function to install a specific package
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
init_sudo_session
clean_system_repositories

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