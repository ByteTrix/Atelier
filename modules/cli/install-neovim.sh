#!/usr/bin/env bash
#
# Neovim Installation
# -----------------
# Installs Neovim text editor with basic configuration
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[neovim] Installing Neovim..."

# Check if Neovim is already installed
if ! command -v nvim &> /dev/null; then
    # Add Neovim repository
    log_info "[neovim] Adding Neovim repository..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    
    # Update and install Neovim
    log_info "[neovim] Installing Neovim and dependencies..."
    sudo apt-get update
    sudo apt-get install -y neovim python3-neovim

    # Create config directory if it doesn't exist
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    mkdir -p "$NVIM_CONFIG_DIR"

    # Create basic init.vim configuration
    log_info "[neovim] Creating basic configuration..."
    cat > "$NVIM_CONFIG_DIR/init.vim" << 'EOF'
" Basic Settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set expandtab          " Use spaces instead of tabs
set tabstop=4          " Number of spaces tabs count for
set shiftwidth=4       " Size of an indent
set smartindent        " Insert indents automatically
set ignorecase         " Case insensitive search
set smartcase          " Case sensitive if capital letter present
set termguicolors      " Enable true color support
set mouse=a            " Enable mouse support
set clipboard+=unnamedplus  " Use system clipboard
set updatetime=300     " Faster completion
set timeoutlen=500     " By default timeoutlen is 1000 ms
set signcolumn=yes     " Always show signcolumn

" Key Mappings
let mapleader = " "    " Set leader key to space
inoremap jk <Esc>      " Map jk to escape in insert mode

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Better indenting
vnoremap < <gv
vnoremap > >gv

" Move selected line / block of text in visual mode
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv
EOF

    log_success "[neovim] Neovim installed successfully!"
else
    log_warn "[neovim] Neovim is already installed."
fi