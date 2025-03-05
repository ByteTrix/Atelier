#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check for required commands
required_commands=("snap")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "[mobile] Required command not found: $cmd"
        return 1
    fi
done

# Check if Flutter is already installed
if command -v flutter &> /dev/null; then
    log_warn "[mobile] Flutter SDK is already installed"
    flutter --version
    return 0
fi

log_info "[mobile] Installing Flutter SDK..."

# Install Flutter using snap
if ! snap install flutter --classic; then
    log_error "[mobile] Failed to install Flutter SDK"
    return 1
fi

# Verify installation
if ! flutter --version; then
    log_error "[mobile] Failed to verify Flutter installation"
    return 1
fi

log_success "[mobile] Flutter SDK installed successfully!"

# Display help information
log_info "[mobile] Quick start guide:"
echo "
Flutter Commands:
- Check version: flutter --version
- Create new project: flutter create my_app
- Run application: flutter run
- Build release: flutter build
- Update Flutter: flutter upgrade
- Doctor check: flutter doctor

Development:
- Android Studio or VS Code recommended
- Run 'flutter doctor' to check dependencies
- Enable developer mode on your device

Resources:
- Documentation: https://flutter.dev/docs
- Samples: flutter create --sample=
- Packages: https://pub.dev

Note: You may need to restart your terminal for Flutter commands to work
"
