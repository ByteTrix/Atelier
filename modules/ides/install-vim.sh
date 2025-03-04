#!/usr/bin/env bash
#
# Vim Installation
# --------------
# Installs Vim text editor with basic configuration
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[vim] Installing and configuring Vim..."

# Install Vim if not present
if ! command -v vim &> /dev/null; then
    log_info "[vim] Installing Vim..."
    sudo apt-get update
    sudo apt-get install -y vim vim-gtk3
else
    log_info "[vim] Vim is already installed, proceeding with configuration..."
fi

# Create vim configuration directory
mkdir -p "$HOME/.vim/"{bundle,colors,autoload}

# Download and install vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    log_info "[vim] Installing vim-plug plugin manager..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Create basic vimrc configuration
log_info "[vim] Creating basic Vim configuration..."
cat > "$HOME/.vimrc" << 'EOF'
" vim-plug plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'           " Sensible defaults
Plug 'tpope/vim-commentary'         " Easy commenting
Plug 'preservim/nerdtree'          " File explorer
Plug 'itchyny/lightline.vim'       " Status line
Plug 'airblade/vim-gitgutter'      " Git diff in the sign column
Plug 'tpope/vim-fugitive'          " Git integration
Plug 'junegunn/fzf.vim'            " Fuzzy finder
call plug#end()

" Basic settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set expandtab          " Use spaces instead of tabs
set tabstop=4          " Number of spaces tabs count for
set shiftwidth=4       " Size of an indent
set smartindent        " Insert indents automatically
set ignorecase         " Case insensitive search
set smartcase          " Case sensitive if capital letter present
set hlsearch           " Highlight search results
set incsearch          " Incremental search
set hidden             " Enable background buffers
set nobackup           " Don't create backup files
set nowritebackup      " Don't create backup files while editing
set noswapfile         " Don't create swap files
set mouse=a            " Enable mouse support
set clipboard=unnamedplus  " Use system clipboard
set updatetime=300     " Faster completion
set scrolloff=8        " Start scrolling before cursor reaches edge
set colorcolumn=80     " Show column guide
set signcolumn=yes     " Always show sign column

" Color scheme
syntax enable
set background=dark

" Key mappings
let mapleader = " "    " Set leader key to space

" NERDTree mappings
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" Buffer navigation
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>l :bnext<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Quick save
nnoremap <leader>w :w<CR>

" Clear search highlighting
nnoremap <leader>c :nohl<CR>

" Status line configuration
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" Auto-install plugins on first launch
if empty(glob('~/.vim/plugged'))
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
EOF

# Install plugins
log_info "[vim] Installing Vim plugins..."
vim +PlugInstall +qall

log_success "[vim] Vim installation and configuration complete!"

# Display help information
log_info "[vim] Quick start guide:"
echo "
Basic Commands:
- :e filename    - Edit a file
- :w            - Save file
- :q            - Quit
- :q!           - Quit without saving
- <Space>n      - Toggle NERDTree
- <Space>w      - Quick save
- <Space>c      - Clear search highlighting
- Ctrl+h/j/k/l  - Navigate splits
- <Space>h/l    - Navigate buffers

Plugin Management:
- :PlugInstall  - Install plugins
- :PlugUpdate   - Update plugins
- :PlugClean    - Remove unused plugins

For more information:
- Run 'vimtutor' in terminal for an interactive tutorial
- Type ':help' in Vim for built-in documentation
"

# Verify installation
if command -v vim &> /dev/null; then
    log_info "[vim] Vim installation verified."
    vim --version | head -n1
else
    log_error "[vim] Vim installation could not be verified."
fi