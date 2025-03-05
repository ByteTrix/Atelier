#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if kubectl is already installed
if command -v kubectl &>/dev/null; then
    log_warn "[containers] kubectl is already installed"
    kubectl version --client
    return 0
fi

log_info "[containers] Installing kubectl..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || {
    log_error "[containers] Failed to create temporary directory"
    return 1
}

# Get latest stable version
STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
if [ -z "$STABLE_VERSION" ]; then
    log_error "[containers] Failed to get stable kubectl version"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Download kubectl
log_info "[containers] Downloading kubectl ${STABLE_VERSION}..."
if ! curl -LO "https://dl.k8s.io/release/${STABLE_VERSION}/bin/linux/amd64/kubectl"; then
    log_error "[containers] Failed to download kubectl"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Install kubectl
log_info "[containers] Installing kubectl..."
if ! sudo_exec install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; then
    log_error "[containers] Failed to install kubectl"
    rm -rf "$TEMP_DIR"
    return 1
fi

# Cleanup
cd - &>/dev/null || true
rm -rf "$TEMP_DIR"

# Verify installation
if command -v kubectl &>/dev/null; then
    log_success "[containers] kubectl installed successfully"
    kubectl version --client
    return 0
else
    log_error "[containers] kubectl installation could not be verified"
    return 1
fi
