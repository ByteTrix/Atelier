#!/usr/bin/env bash
#
# Apache Cordova Installation
# ------------------------
# Installs Apache Cordova and related tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[cordova] Installing Apache Cordova..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_info "[cordova] Node.js is required. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "[cordova] npm is not installed. Please install Node.js properly."
    exit 1
fi

# Install Android Studio if not present (required for Android development)
if ! command -v studio &> /dev/null; then
    log_info "[cordova] Android Studio is required. Installing..."
    bash "${SCRIPT_DIR}/install-android-studio.sh"
fi

# Install Cordova CLI
log_info "[cordova] Installing Cordova CLI..."
npm install -g cordova

# Install system dependencies
log_info "[cordova] Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    gradle \
    openjdk-11-jdk \
    android-tools-adb \
    lib32z1 \
    lib32ncurses6 \
    lib32stdc++6

# Create Cordova workspace
CORDOVA_WORKSPACE="$HOME/cordova-projects"
mkdir -p "$CORDOVA_WORKSPACE"

# Add environment variables to .bashrc
log_info "[cordova] Setting up environment variables..."
cat >> "$HOME/.bashrc" << 'EOF'

# Cordova environment variables
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
EOF

# Source the new environment variables
source "$HOME/.bashrc"

# Create example project
log_info "[cordova] Creating example project..."
cd "$CORDOVA_WORKSPACE"
cordova create CordovaExample com.example.cordova CordovaExample
cd CordovaExample

# Add Android platform
log_info "[cordova] Adding Android platform..."
cordova platform add android

# Add some common plugins
log_info "[cordova] Adding common Cordova plugins..."
cordova plugin add cordova-plugin-device
cordova plugin add cordova-plugin-camera
cordova plugin add cordova-plugin-geolocation
cordova plugin add cordova-plugin-file
cordova plugin add cordova-plugin-inappbrowser

log_success "[cordova] Apache Cordova installed successfully!"

# Display help information
log_info "[cordova] Quick start guide:"
echo "
Cordova Development:
- Create new project: cordova create ProjectName com.example.app AppName
- Add platform: cordova platform add android/ios
- Build project: cordova build android/ios
- Run on device: cordova run android/ios
- Run in browser: cordova run browser

Development Tools:
- Cordova CLI: Command line interface
- Android Studio: Required for Android development
- Xcode: Required for iOS development (Mac only)
- Chrome DevTools: For debugging web content

Example Project:
- Location: $CORDOVA_WORKSPACE/CordovaExample
- To run:
  1. cd $CORDOVA_WORKSPACE/CordovaExample
  2. cordova prepare
  3. cordova run android

Common Commands:
- Check requirements: cordova requirements
- Add plugin: cordova plugin add plugin-name
- List plugins: cordova plugin list
- Remove plugin: cordova plugin remove plugin-name
- Update platform: cordova platform update android/ios
- Clean project: cordova clean
- Build release: cordova build android --release

Project Structure:
- www/: Web application source files
- platforms/: Platform-specific build files
- plugins/: Cordova plugins
- config.xml: Project configuration

Environment:
- Cordova workspace: $CORDOVA_WORKSPACE
- Android SDK: $HOME/Android/Sdk
- Example project: $CORDOVA_WORKSPACE/CordovaExample

Note: 
- For iOS development, you need a Mac with Xcode installed
- Browser platform can be used for quick testing
"

# Verify installation
log_info "[cordova] Verifying installation..."
echo "Node.js version:"
node --version
echo -e "\nNPM version:"
npm --version
echo -e "\nCordova version:"
cordova --version