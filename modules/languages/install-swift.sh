#!/usr/bin/env bash
#
# Swift Installation
# ----------------
# Installs Swift programming language and related tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[swift] Installing Swift..."

# Check if Swift is already installed
if ! command -v swift &> /dev/null; then
    # Install dependencies
    log_info "[swift] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y \
        binutils \
        git \
        gnupg2 \
        libc6-dev \
        libcurl4-openssl-dev \
        libedit2 \
        libgcc-9-dev \
        libpython2.7 \
        libsqlite3-0 \
        libstdc++-9-dev \
        libxml2 \
        libz3-dev \
        pkg-config \
        tzdata \
        uuid-dev \
        zlib1g-dev

    # Determine system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "aarch64" ]; then
        log_error "[swift] Unsupported architecture: $ARCH"
        exit 1
    fi

    # Get Ubuntu version
    source /etc/os-release
    UBUNTU_VERSION="$VERSION_ID"

    # Download and install Swift
    log_info "[swift] Downloading Swift..."
    SWIFT_VERSION="5.9.2"
    SWIFT_PLATFORM="ubuntu${UBUNTU_VERSION}"
    SWIFT_BRANCH="swift-${SWIFT_VERSION}-release"
    SWIFT_TAG="swift-${SWIFT_VERSION}-RELEASE"
    SWIFT_FILE="swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz"
    SWIFT_URL="https://swift.org/builds/${SWIFT_BRANCH}/$(echo "$SWIFT_PLATFORM" | tr '.' '_')/${SWIFT_TAG}/${SWIFT_FILE}"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download Swift
    wget "$SWIFT_URL"
    wget "$SWIFT_URL.sig"

    # Import Swift keys
    wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -
    gpg --verify "$SWIFT_FILE.sig" "$SWIFT_FILE"

    # Extract Swift
    log_info "[swift] Installing Swift..."
    sudo mkdir -p /opt/swift
    sudo tar xzf "$SWIFT_FILE" -C /opt/swift --strip-components=1
    
    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    # Add Swift to PATH
    echo 'export PATH="/opt/swift/usr/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="/opt/swift/usr/bin:$PATH"

    # Create Swift toolchain directory
    mkdir -p "$HOME/.swift/toolchains"

    log_success "[swift] Swift installed successfully!"
    
    # Display help information
    log_info "[swift] Quick start guide:"
    echo "
    Swift:
    - Check version: swift --version
    - Start REPL: swift
    - Create new package: swift package init --type executable
    - Build package: swift build
    - Run tests: swift test
    - Update dependencies: swift package update
    
    Common Commands:
    - Compile source: swiftc file.swift
    - Run program: ./file
    - Generate Xcode project: swift package generate-xcodeproj
    
    Package Development:
    - Package manifest: Package.swift
    - Source directory: Sources/
    - Tests directory: Tests/
    
    Environment:
    - Swift installation: /opt/swift
    - Swift toolchain: $HOME/.swift/toolchains
    - Restart your terminal or run 'source ~/.bashrc' to update PATH
    "
else
    log_warn "[swift] Swift is already installed."
fi

# Verify installation
log_info "[swift] Verifying installation..."
swift --version

# Create example Swift program
log_info "[swift] Creating example Swift program..."
mkdir -p "$HOME/swift-examples"
cat > "$HOME/swift-examples/hello.swift" << 'EOF'
print("Hello from Swift!")
EOF

log_info "[swift] You can run the example program with:"
echo "swift $HOME/swift-examples/hello.swift"