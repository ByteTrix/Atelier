#!/usr/bin/env bash
#
# React Native Installation
# ----------------------
# Installs React Native development environment
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[react-native] Installing React Native development environment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_info "[react-native] Node.js is required. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "[react-native] npm is not installed. Please install Node.js properly."
    exit 1
fi

# Install Android Studio if not present (required for Android development)
if ! command -v studio &> /dev/null; then
    log_info "[react-native] Android Studio is required. Installing..."
    bash "${SCRIPT_DIR}/install-android-studio.sh"
fi

# Install React Native CLI
log_info "[react-native] Installing React Native CLI..."
npm install -g react-native-cli

# Install additional dependencies
log_info "[react-native] Installing additional dependencies..."
sudo apt-get update
sudo apt-get install -y \
    openjdk-11-jdk \
    adb \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    lib32z1 \
    libbz2-1.0:i386

# Create React Native workspace
RN_WORKSPACE="$HOME/react-native-projects"
mkdir -p "$RN_WORKSPACE"

# Add environment variables to .bashrc
log_info "[react-native] Setting up environment variables..."
cat >> "$HOME/.bashrc" << 'EOF'

# React Native environment variables
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
EOF

# Source the new environment variables
source "$HOME/.bashrc"

# Create example project
log_info "[react-native] Creating example project..."
cd "$RN_WORKSPACE"
npx react-native init ExampleProject

log_success "[react-native] React Native development environment installed successfully!"

# Display help information
log_info "[react-native] Quick start guide:"
echo "
React Native Development:
- Create new project: npx react-native init ProjectName
- Run Android app: 
  1. Start Android emulator
  2. cd ProjectName
  3. npx react-native run-android

- Run iOS app (requires macOS):
  1. cd ProjectName
  2. npx react-native run-ios

Development Tools:
- Android Studio: Required for Android development
- Metro Bundler: Starts automatically when running app
- React Native Debugger: Optional but recommended

Example Project:
- Location: $RN_WORKSPACE/ExampleProject
- To run:
  1. cd $RN_WORKSPACE/ExampleProject
  2. npx react-native start
  3. npx react-native run-android (in another terminal)

Common Commands:
- Start Metro: npx react-native start
- Run Android: npx react-native run-android
- Create release build: cd android && ./gradlew assembleRelease
- Install dependencies: npm install
- Link native dependencies: npx react-native link

Environment:
- Android SDK: $HOME/Android/Sdk
- Workspace: $RN_WORKSPACE
- Example project: $RN_WORKSPACE/ExampleProject

Note: For iOS development, you need a Mac with Xcode installed.
"

# Verify installation
log_info "[react-native] Verifying installation..."
echo "Node.js version:"
node --version
echo -e "\nNPM version:"
npm --version
echo -e "\nReact Native CLI version:"
npx react-native --version