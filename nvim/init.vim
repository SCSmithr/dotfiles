" Neovim configuration

" Plugins (vim-plug)
call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

call plug#end()

" Tabs
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent

" Show line numbers
set number

" Mouse
set mouse=a

" Search
set hlsearch
set incsearch
set showmatch

" Cursor
set guicursor= " Always use block cursor

" Buffers
set hidden " switch between buffers without saving

" Status line
set laststatus=2

set statusline=
set statusline +=%f\ %m\ %r\ %*     " file name, modified, readonly
set statusline +=%=                 " left/ right separator
set statusline +=%c\ :\ %l/%L%*     " cursor column, current line, total

" Syntax
set termguicolors
colorscheme base16-two

" Plugin settings

" NERDTree settings
" Expand dir, open files with single click
let NERDTreeMouseMode = 3
let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1

" Shortcuts

" Leader
let mapleader = ","

" Cycle between buffers with leader-a and leader-s
map <leader>a :bp<CR>
map <leader>s :bn<CR>

" Clear search highlight with leader-c
map <leader>c :nohlsearch<CR>

" Toggle nerdtree with leader-n
map <leader>n :NERDTreeToggle<CR>
