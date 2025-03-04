#!/usr/bin/env bash
#
# Ionic Installation
# ----------------
# Installs Ionic Framework and related tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[ionic] Installing Ionic Framework..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_info "[ionic] Node.js is required. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "[ionic] npm is not installed. Please install Node.js properly."
    exit 1
fi

# Install Android Studio if not present (required for Android development)
if ! command -v studio &> /dev/null; then
    log_info "[ionic] Android Studio is required. Installing..."
    bash "${SCRIPT_DIR}/install-android-studio.sh"
fi

# Install Ionic CLI
log_info "[ionic] Installing Ionic CLI..."
npm install -g @ionic/cli

# Install additional dependencies
log_info "[ionic] Installing additional dependencies..."
npm install -g cordova
npm install -g native-run
npm install -g @capacitor/cli

# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
    gradle \
    openjdk-11-jdk \
    android-tools-adb

# Create Ionic workspace
IONIC_WORKSPACE="$HOME/ionic-projects"
mkdir -p "$IONIC_WORKSPACE"

# Add environment variables to .bashrc
log_info "[ionic] Setting up environment variables..."
cat >> "$HOME/.bashrc" << 'EOF'

# Ionic environment variables
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
EOF

# Source the new environment variables
source "$HOME/.bashrc"

# Create example project
log_info "[ionic] Creating example project..."
cd "$IONIC_WORKSPACE"
ionic start IonicExample blank --type angular --capacitor

# Initialize Capacitor in the example project
cd IonicExample
npm install @capacitor/android @capacitor/ios
ionic cap add android

log_success "[ionic] Ionic Framework installed successfully!"

# Display help information
log_info "[ionic] Quick start guide:"
echo "
Ionic Development:
- Create new project: ionic start ProjectName template
  Templates: blank, tabs, sidemenu
  Frameworks: angular, react, vue
- Serve project: ionic serve
- Build project: ionic build
- Add platform: ionic cap add android/ios
- Open in IDE: ionic cap open android/ios
- Live reload: ionic cap run android -l --external

Development Tools:
- Ionic CLI: Command line interface
- Capacitor: Native runtime
- Android Studio: Required for Android development
- Xcode: Required for iOS development (Mac only)

Example Project:
- Location: $IONIC_WORKSPACE/IonicExample
- To run:
  1. cd $IONIC_WORKSPACE/IonicExample
  2. ionic serve (web preview)
  3. ionic cap sync (update native)
  4. ionic cap run android (on device/emulator)

Common Commands:
- Generate page: ionic g page PageName
- Generate service: ionic g service ServiceName
- Generate component: ionic g component ComponentName
- Build production: ionic build --prod
- Sync with native: ionic cap sync
- Copy web assets: ionic cap copy
- Update native plugins: ionic cap update

Environment:
- Ionic workspace: $IONIC_WORKSPACE
- Android SDK: $HOME/Android/Sdk
- Example project: $IONIC_WORKSPACE/IonicExample

Note: For iOS development, you need a Mac with Xcode installed.
"

# Verify installation
log_info "[ionic] Verifying installation..."
echo "Node.js version:"
node --version
echo -e "\nNPM version:"
npm --version
echo -e "\nIonic CLI version:"
ionic --version