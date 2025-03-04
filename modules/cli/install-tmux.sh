#!/usr/bin/env bash
#
# Tmux Installation
# ---------------
# Installs Tmux terminal multiplexer
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[tmux] Installing Tmux..."

# Check if Tmux is already installed
if ! command -v tmux &> /dev/null; then
    # Install build dependencies
    log_info "[tmux] Installing build dependencies..."
    sudo apt-get update
    sudo apt-get install -y tmux

    # Create default tmux configuration
    if [ ! -f "$HOME/.tmux.conf" ]; then
        log_info "[tmux] Creating default configuration..."
        cat > "$HOME/.tmux.conf" << 'EOF'
# Improve colors
set -g default-terminal "screen-256color"

# Set scrollback buffer to 10000
set -g history-limit 10000

# Enable mouse mode
set -g mouse on

# Customize status bar
set -g status-bg black
set -g status-fg white
set -g status-left ""
set -g status-right "#[fg=green]#H #[fg=white]• #[fg=yellow]%H:%M #[fg=white]• #[fg=cyan]%d-%b-%y"

# Start window numbering at 1
set -g base-index 1

# Reload config with prefix-r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"
EOF
    fi

    log_success "[tmux] Tmux installed successfully!"
else
    log_warn "[tmux] Tmux is already installed."
fi