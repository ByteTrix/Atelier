#!/usr/bin/env bash
#
# Setupr Installation Menu
# -----------------------
# Interactive menu for selecting packages

# Determine script directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/lib/utils.sh"

log_info "Initializing installation menu..."

# Define all available options with descriptions and categories
declare -A PACKAGES=(
  # Languages
  ["[Languages] Python"]="python3:apt python3-pip:apt"
  ["[Languages] Node.js"]="nodejs:apt npm:apt"
  ["[Languages] Ruby"]="ruby:apt ruby-bundler:apt"
  ["[Languages] Golang"]="golang:apt"
  ["[Languages] Rust"]="rustc:apt cargo:apt"
  ["[Languages] Java"]="default-jdk:apt default-jre:apt"
  ["[Languages] PHP"]="php:apt php-cli:apt php-fpm:apt"
  ["[Languages] Perl"]="perl:apt cpanminus:apt"
  ["[Languages] Swift"]="swift:apt"
  ["[Languages] Kotlin"]="kotlin:apt"
  
  # IDEs & Editors
  ["[IDEs] Visual Studio Code"]="code:vscode"
  ["[IDEs] Sublime Text"]="sublime-text:apt"
  ["[IDEs] Vim"]="vim:apt"
  ["[IDEs] NeoVim"]="nvim:snap"
  ["[IDEs] PyCharm Community"]="pycharm-community:snap"
  ["[IDEs] IntelliJ IDEA Community"]="intellij-idea-community:snap"
  ["[IDEs] Android Studio"]="android-studio:snap"
  
  # Browsers
  ["[Browsers] Firefox"]="firefox:snap"
  ["[Browsers] Chrome"]="google-chrome-stable:apt"
  ["[Browsers] Brave"]="brave-browser:apt"
  ["[Browsers] Opera"]="opera-stable:apt"
  
  # Development Tools
  ["[Dev] Postman"]="postman:snap"
  ["[Dev] Docker"]="docker:apt docker-compose:apt"
  ["[Dev] GitKraken"]="gitkraken:snap"
  ["[Dev] DBeaver"]="dbeaver-ce:snap"
  
  # Communication
  ["[Communication] Discord"]="discord:snap"
  ["[Communication] Slack"]="slack:snap"
  ["[Communication] Telegram"]="telegram-desktop:snap"
  ["[Communication] Signal"]="signal-desktop:snap"
  ["[Communication] Teams"]="teams:snap"
  
  # Media
  ["[Media] VLC"]="vlc:snap"
  ["[Media] Spotify"]="spotify:snap"
  ["[Media] OBS Studio"]="obs-studio:snap"
  ["[Media] Kdenlive"]="kdenlive:snap"
  ["[Media] GIMP"]="gimp:snap"
  ["[Media] Inkscape"]="inkscape:snap"
  
  # Productivity
  ["[Productivity] LibreOffice"]="libreoffice:snap"
  ["[Productivity] Obsidian"]="obsidian:snap"
  ["[Productivity] Notion"]="notion-snap:snap"
  ["[Productivity] Bitwarden"]="bitwarden:snap"
  
  # CLI Tools
  ["[CLI] Tmux"]="tmux:apt"
  ["[CLI] Ripgrep"]="ripgrep:apt"
  ["[CLI] fzf"]="fzf:apt"
  ["[CLI] bat"]="bat:apt"
  ["[CLI] exa"]="exa:apt"
  ["[CLI] jq"]="jq:apt"
  ["[CLI] htop"]="htop:apt"
  ["[CLI] ncdu"]="ncdu:apt"
)

# Check for gum
if ! command -v gum &> /dev/null; then
  log_error "'gum' command not found. Please install gum first."
  exit 1
fi

# Extract descriptions for gum menu
DESCRIPTIONS=("${!PACKAGES[@]}")

# Display interactive selection menu
log_info "Displaying package selection menu..."

SELECTED=$(gum choose \
  --no-limit \
  --height 20 \
  --header "📦 Package Installation" \
  --header.foreground="99" \
  --header "Select packages to install (space to select, enter to confirm):" \
  "${DESCRIPTIONS[@]}") || {
    log_error "Failed to display selection menu"
    exit 1
  }

# Handle empty selection
if [ -z "$SELECTED" ]; then
  log_warn "No packages selected"
  exit 0
fi

# Output selected package strings
while IFS= read -r SELECTION; do
  echo "${PACKAGES[$SELECTION]}"
done <<< "$SELECTED"