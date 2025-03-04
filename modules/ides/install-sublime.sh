#!/usr/bin/env bash
#
# Sublime Text Installation
# ----------------------
# Installs Sublime Text editor
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[sublime] Installing Sublime Text..."

# Check if Sublime Text is already installed
if ! command -v subl &> /dev/null; then
    # Install dependencies
    log_info "[sublime] Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y wget apt-transport-https

    # Add Sublime Text GPG key
    log_info "[sublime] Adding Sublime Text repository..."
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

    # Add Sublime Text repository
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    # Update package lists and install Sublime Text
    sudo apt-get update
    sudo apt-get install -y sublime-text

    # Create initial configuration directory
    mkdir -p "$HOME/.config/sublime-text-3/Packages/User"

    # Create basic configuration
    log_info "[sublime] Creating basic configuration..."
    cat > "$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings" << 'EOF'
{
    "font_size": 11,
    "theme": "Adaptive.sublime-theme",
    "color_scheme": "Monokai.sublime-color-scheme",
    "ensure_newline_at_eof_on_save": true,
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true,
    "word_wrap": true,
    "highlight_line": true,
    "auto_complete": true,
    "show_encoding": true,
    "show_line_endings": true,
    "rulers": [80, 100],
    "save_on_focus_lost": true,
    "folder_exclude_patterns": [
        ".svn",
        ".git",
        ".hg",
        "CVS",
        "node_modules"
    ]
}
EOF

    log_success "[sublime] Sublime Text installed successfully!"
    
    # Display help information
    log_info "[sublime] Quick start guide:"
    echo "
    - Launch Sublime Text: subl
    - Open Command Palette: Ctrl+Shift+P
    - Install Package Control: View -> Show Console, then paste:
      import urllib.request,os,hashlib; h = '6f4c264a24d933ce70df5dedcf1dcaee' + 'ebe013ee18cced0ef93d5f746d80ef60'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); open(os.path.join( ipp, pf), 'wb' ).write(by)
    - Install packages: Ctrl+Shift+P, then type 'Install Package'
    "
else
    log_warn "[sublime] Sublime Text is already installed."
fi

# Verify installation
if command -v subl &> /dev/null; then
    log_info "[sublime] Sublime Text installation verified."
    subl --version
else
    log_error "[sublime] Sublime Text installation could not be verified."
fi