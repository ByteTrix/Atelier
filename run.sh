#!/bin/bash

# Script to set up and run Setupr

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Check if setupr is installed
if ! pip list | grep -q setupr; then
    echo "Installing Setupr in development mode..."
    pip install -e .
fi

# Run Setupr
echo "Starting Setupr..."
python -m setupr.main

# Don't deactivate automatically, keep terminal in venv
echo ""
echo "Setupr has exited. Virtual environment is still active."
echo "Type 'deactivate' when you're done to exit the virtual environment."
