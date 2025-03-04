#!/usr/bin/env bash
#
# Xamarin Installation
# ------------------
# Installs Xamarin development environment for cross-platform mobile development
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[xamarin] Installing Xamarin development environment..."

# Check if Mono is installed
if ! command -v mono &> /dev/null; then
    # Install Mono
    log_info "[xamarin] Installing Mono..."
    
    # Add Mono repository
    sudo apt-get install -y gnupg ca-certificates
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
    
    # Install Mono
    sudo apt-get update
    sudo apt-get install -y mono-complete
fi

# Install .NET SDK
if ! command -v dotnet &> /dev/null; then
    log_info "[xamarin] Installing .NET SDK..."
    
    # Add Microsoft package repository
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    # Install .NET SDK
    sudo apt-get update
    sudo apt-get install -y apt-transport-https
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-6.0
fi

# Install Android Studio if not present (required for Android development)
if ! command -v studio &> /dev/null; then
    log_info "[xamarin] Android Studio is required. Installing..."
    bash "${SCRIPT_DIR}/install-android-studio.sh"
fi

# Install additional dependencies
log_info "[xamarin] Installing additional dependencies..."
sudo apt-get install -y \
    git \
    nuget \
    msbuild \
    gtk-sharp3

# Create Xamarin workspace
XAMARIN_WORKSPACE="$HOME/xamarin-projects"
mkdir -p "$XAMARIN_WORKSPACE"

# Install Visual Studio Code if not present
if ! command -v code &> /dev/null; then
    log_info "[xamarin] Installing Visual Studio Code..."
    sudo snap install code --classic
fi

# Install recommended VS Code extensions
log_info "[xamarin] Installing recommended VS Code extensions..."
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension xamarin.xamarin-android-extension-pack

# Create example project
log_info "[xamarin] Creating example project..."
cd "$XAMARIN_WORKSPACE"
dotnet new android -n XamarinExample

log_success "[xamarin] Xamarin development environment installed successfully!"

# Display help information
log_info "[xamarin] Quick start guide:"
echo "
Xamarin Development:
- Create new Android project: dotnet new android -n ProjectName
- Build project: dotnet build
- Run project on Android: dotnet run

Development Tools:
- Visual Studio Code with C# extension
- Android Studio for Android SDK and emulator
- Mono for .NET framework support
- .NET SDK for development

Example Project:
- Location: $XAMARIN_WORKSPACE/XamarinExample
- To run:
  1. cd $XAMARIN_WORKSPACE/XamarinExample
  2. dotnet build
  3. dotnet run

Common Commands:
- Create solution: dotnet new sln
- Add project to solution: dotnet sln add ProjectName
- Restore packages: dotnet restore
- Clean build: dotnet clean
- Run tests: dotnet test

Environment:
- Xamarin workspace: $XAMARIN_WORKSPACE
- Android SDK: $HOME/Android/Sdk
- Example project: $XAMARIN_WORKSPACE/XamarinExample

Note: 
- For iOS development, you need a Mac with Xcode installed
- Visual Studio for Mac is recommended for full Xamarin development experience on macOS
"

# Verify installation
log_info "[xamarin] Verifying installation..."
echo "Mono version:"
mono --version
echo -e "\n.NET SDK version:"
dotnet --version
echo -e "\nMSBuild version:"
msbuild --version