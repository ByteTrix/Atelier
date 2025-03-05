#!/usr/bin/env bash
# Determine the directory of the current script.
DIR="$(dirname "$(realpath "$0")")"
# Source the shared utilities file from the repository root.
source "$DIR/../../lib/utils.sh"

# Check for required commands
required_commands=("apt")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "[languages] Required command not found: $cmd"
        return 1
    fi
done

# Check if Go is already installed
if command -v go &> /dev/null; then
    log_warn "[languages] Golang is already installed"
    go version
    return 0
fi

log_info "[languages] Installing Golang..."

# Update package list
if ! sudo apt-get update; then
    log_error "[languages] Failed to update package list"
    return 1
fi

# Install Go
if ! sudo apt install -y golang; then
    log_error "[languages] Failed to install Golang"
    return 1
fi

# Verify installation
if ! go version; then
    log_error "[languages] Failed to verify Golang installation"
    return 1
fi

log_success "[languages] Golang installation complete."

# Set up Go workspace
GOPATH="$HOME/go"
if ! mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"; then
    log_warn "[languages] Failed to create Go workspace directories"
fi

# Add Go environment variables to bashrc if not already present
if ! grep -q "GOPATH" "$HOME/.bashrc"; then
    {
        echo 'export GOPATH="$HOME/go"'
        echo 'export PATH="$PATH:$GOPATH/bin"'
    } >> "$HOME/.bashrc"
fi

# Display help information
log_info "[languages] Quick start guide:"
echo "
Go Environment:
- GOPATH: $GOPATH
- Check version: go version
- Run a program: go run file.go
- Build a program: go build file.go
- Get a package: go get package-name
- Run tests: go test
- Format code: go fmt

Workspace Structure:
- Source code: $GOPATH/src
- Compiled packages: $GOPATH/pkg
- Compiled commands: $GOPATH/bin

Note: Restart your terminal or run 'source ~/.bashrc' to update PATH
"
