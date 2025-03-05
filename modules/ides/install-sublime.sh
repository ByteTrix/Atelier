#!/usr/bin/env bash
#
# Sublime Text Installation
# ----------------------
# Installs Sublime Text editor
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check if Sublime Text is already installed
if command -v subl &>/dev/null; then
    log_warn "[sublime] Sublime Text is already installed"
    subl --version
    return 0
fi

log_info "[sublime] Installing Sublime Text..."

# Install dependencies
log_info "[sublime] Installing dependencies..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y wget apt-transport-https gpg; then
    log_error "[sublime] Failed to install dependencies"
    return 1
fi

# Create keyrings directory
sudo_exec mkdir -p /usr/share/keyrings

# Add Sublime Text GPG key
log_info "[sublime] Adding Sublime Text repository key..."
if ! wget -qO- https://download.sublimetext.com/sublimehq-pub.gpg | sudo_exec gpg --dearmor -o /usr/share/keyrings/sublime-text.gpg; then
    log_error "[sublime] Failed to add repository key"
    return 1
fi

# Add Sublime Text repository
log_info "[sublime] Adding Sublime Text repository..."
if ! echo "deb [signed-by=/usr/share/keyrings/sublime-text.gpg] https://download.sublimetext.com/ apt/stable/" | sudo_exec tee /etc/apt/sources.list.d/sublime-text.list > /dev/null; then
    log_error "[sublime] Failed to add repository"
    return 1
fi

# Update package lists and install Sublime Text
log_info "[sublime] Installing Sublime Text..."
if ! sudo_exec apt-get update || ! sudo_exec apt-get install -y sublime-text; then
    log_error "[sublime] Failed to install Sublime Text"
    return 1
fi

# Create initial configuration directory
CONFIG_DIR="$HOME/.config/sublime-text-3/Packages/User"
if ! mkdir -p "$CONFIG_DIR"; then
    log_warn "[sublime] Failed to create configuration directory"
fi

# Create basic configuration
log_info "[sublime] Creating basic configuration..."
CONFIG_FILE="$CONFIG_DIR/Preferences.sublime-settings"
if ! cat > "$CONFIG_FILE" << 'EOF'; then
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
    log_warn "[sublime] Failed to create configuration file"
fi

# Verify installation
if command -v subl &>/dev/null; then
    log_success "[sublime] Sublime Text installed successfully"
    subl --version
    
    # Display help information
    log_info "[sublime] Quick start guide:"
    echo "
    - Launch Sublime Text: subl
    - Open Command Palette: Ctrl+Shift+P
    - Install Package Control: View -> Show Console, then paste:
      import urllib.request,os,hashlib; h = '6f4c264a24d933ce70df5dedcf1dcaee' + 'ebe013ee18cced0ef93d5f746d80ef60'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); open(os.path.join( ipp, pf), 'wb' ).write(by)
    - Install packages: Ctrl+Shift+P, then type 'Install Package'
    "
    return 0
else
    log_error "[sublime] Sublime Text installation could not be verified"
    return 1
fi