#!/usr/bin/env bash
#
# Swift Installation
# ----------------
# Installs Swift programming language and related tools
#
# Author: Atelier Team
# License: MIT

# Source shared utilities
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check for required commands
required_commands=("curl" "tar" "gcc")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command not found: $cmd"
        return 1
    fi
done

log_info "[swift] Installing Swift..."

# Check if Swift is already installed
if ! command -v swift &> /dev/null; then
    # Install dependencies
    log_info "[swift] Installing dependencies..."
    if ! sudo apt-get update; then
        log_error "[swift] Failed to update package list"
        return 1
    fi
    if ! sudo apt-get install -y \
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
        zlib1g-dev; then
        log_error "[swift] Failed to install dependencies"
        return 1
    fi

    # Determine system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "aarch64" ]; then
        log_error "[swift] Unsupported architecture: $ARCH"
        return 1
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
    if ! cd "$TEMP_DIR"; then
        log_error "[swift] Failed to create temporary directory"
        return 1
    fi

    # Download Swift
    if ! wget "$SWIFT_URL"; then
        log_error "[swift] Failed to download Swift"
        return 1
    fi
    if ! wget "$SWIFT_URL.sig"; then
        log_error "[swift] Failed to download Swift signature"
        return 1
    fi

    # Import Swift keys
    if ! wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -; then
        log_error "[swift] Failed to import Swift keys"
        return 1
    fi
    if ! gpg --verify "$SWIFT_FILE.sig" "$SWIFT_FILE"; then
        log_error "[swift] Failed to verify Swift package"
        return 1
    fi

    # Extract Swift
    log_info "[swift] Installing Swift..."
    if ! sudo mkdir -p /opt/swift; then
        log_error "[swift] Failed to create Swift directory"
        return 1
    fi
    if ! sudo tar xzf "$SWIFT_FILE" -C /opt/swift --strip-components=1; then
        log_error "[swift] Failed to extract Swift"
        return 1
    fi
    
    # Clean up
    cd - > /dev/null || true
    rm -rf "$TEMP_DIR"

    # Add Swift to PATH
    echo 'export PATH="/opt/swift/usr/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="/opt/swift/usr/bin:$PATH"

    # Create Swift toolchain directory
    if ! mkdir -p "$HOME/.swift/toolchains"; then
        log_error "[swift] Failed to create toolchain directory"
        return 1
    fi

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
if ! swift --version; then
    log_error "[swift] Failed to verify Swift installation"
    return 1
fi

# Create example Swift program
log_info "[swift] Creating example Swift program..."
if ! mkdir -p "$HOME/swift-examples"; then
    log_error "[swift] Failed to create examples directory"
    return 1
fi
if ! cat > "$HOME/swift-examples/hello.swift" << 'EOF'
print("Hello from Swift!")
EOF
then
    log_error "[swift] Failed to create example program"
    return 1
fi

log_info "[swift] You can run the example program with:"
echo "swift $HOME/swift-examples/hello.swift"