#!/usr/bin/env bash
set -e

echo "Installing Python..."

# Install Python and core tools
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv

# Set up aliases
echo 'alias python=python3' >> "$HOME/.bashrc"
echo 'alias pip=pip3' >> "$HOME/.bashrc"

# Verify installation
echo "Python installed successfully:"
python3 --version
pip3 --version
