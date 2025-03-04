#!/usr/bin/env bash
#
# Python Installation
# ----------------
# Installs Python 3, pip, and common development tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[python] Installing Python development environment..."

# Check if Python 3 is already installed
if ! command -v python3 &> /dev/null; then
    # Install Python 3 and development tools
    log_info "[python] Installing Python 3 and development tools..."
    sudo apt-get update
    sudo apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3-setuptools \
        python3-wheel

    # Create Python aliases if they don't exist
    if ! grep -q "alias python=" "$HOME/.bashrc"; then
        echo 'alias python=python3' >> "$HOME/.bashrc"
        echo 'alias pip=pip3' >> "$HOME/.bashrc"
    fi
else
    log_info "[python] Python 3 is already installed, upgrading pip..."
    python3 -m pip install --upgrade pip
fi

# Install pipx for managing Python applications
if ! command -v pipx &> /dev/null; then
    log_info "[python] Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
fi

# Install common development tools
log_info "[python] Installing common Python development tools..."
python3 -m pip install --user \
    virtualenv \
    pipenv \
    poetry \
    black \
    flake8 \
    mypy \
    pytest \
    ipython

# Create virtual environment directory
VENV_DIR="$HOME/.virtualenvs"
mkdir -p "$VENV_DIR"

# Add virtualenvwrapper-like functionality
if ! grep -q "WORKON_HOME" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << 'EOF'

# Python virtual environment settings
export WORKON_HOME=$HOME/.virtualenvs
export PIPENV_VENV_IN_PROJECT=1

# Create a new virtual environment
mkvenv() {
    python3 -m venv "$WORKON_HOME/$1"
    source "$WORKON_HOME/$1/bin/activate"
    pip install --upgrade pip setuptools wheel
}

# Activate a virtual environment
workon() {
    if [ -d "$WORKON_HOME/$1" ]; then
        source "$WORKON_HOME/$1/bin/activate"
    else
        echo "Virtual environment '$1' not found in $WORKON_HOME"
    fi
}

# List virtual environments
lsvenv() {
    ls -1 "$WORKON_HOME"
}
EOF
fi

log_success "[python] Python development environment installed successfully!"

# Display help information
log_info "[python] Quick start guide:"
echo "
Python Development:
- Create virtual environment: mkvenv myproject
- Activate environment: workon myproject
- List environments: lsvenv
- Install package: pip install package-name
- Run Python: python script.py

Package Management:
- pip: Traditional package installer
- pipenv: Dependencies per project
- poetry: Modern dependency management
- pipx: Install Python applications

Development Tools:
- black: Code formatter
- flake8: Style guide enforcer
- mypy: Static type checker
- pytest: Testing framework
- ipython: Enhanced interactive Python

Virtual Environments:
- Location: $HOME/.virtualenvs
- Project-level: pipenv or poetry
- System-wide: pip install --user

Environment Variables:
- WORKON_HOME: $VENV_DIR
- PIPENV_VENV_IN_PROJECT: 1 (create virtualenv in project directory)

Note: Restart your terminal or run 'source ~/.bashrc' to apply changes.
"

# Verify installation
log_info "[python] Verifying installation..."
echo "Python version:"
python3 --version
echo -e "\npip version:"
pip3 --version
echo -e "\nInstalled tools:"
echo "✓ virtualenv: $(virtualenv --version)"
echo "✓ pipenv: $(pipenv --version)"
echo "✓ poetry: $(poetry --version)"
echo "✓ black: $(black --version)"
echo "✓ flake8: $(flake8 --version)"
