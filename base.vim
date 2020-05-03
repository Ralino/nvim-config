" Base config with sane defaults
" should be kept compatible with vim, nvim and embedded nvim

" Settings {{{
set nocompatible

"FIXME consider using $XDG_CONFIG_HOME/nvim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

filetype plugin indent on
syntax on

set title
set ruler
set showcmd
set incsearch
set nolangremap
set autoindent
set backspace=indent,eol,start
set mouse=a
set number
set relativenumber
set hidden

set belloff=all
set vb
set t_vb=

set undofile
set undodir^=~/.vim/tmp
set backupskip+=/dev/shm/*
"swap files
set dir^=~/.vim/swap,~/.vim/tmp
augroup UNDOFILE
  au!
  au BufWritePre /tmp/* setlocal noundofile
  au BufWritePre /dev/shm/* setlocal noundofile
  au BufWritePre /tmp/* setlocal noswapfile
  au BufWritePre /dev/shm/* setlocal noswapfile
augroup END

set shiftwidth=2
set smarttab

set textwidth=90

set wrap
set scrolloff=2
set sidescrolloff=5
set sidescroll=1
set listchars=extends:►,precedes:◄
inoremap <C-A> <C-O>ze

set wildmenu
set wildmode=longest:full,full

set foldmethod=marker
set spelllang=de,en_us

let mapleader = " "
let maplocalleader = " "

set guioptions-=m guioptions-=T guioptions-=L

augroup JUMPTOLASTCURSORPOS
  au!
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END

" }}}

" Commands {{{

command! Retrail :%s/\s\+$//e

"I am bad at typing, okay? :(
command! W :w
command! Wq :wq
command! WQ :wq
command! Q :q
command! Qa :qa
command! QA :qa

if !has("nvim")
  command! SudoW :w !sudo tee % > /dev/null
endif

command! CopyFilename :let @+=expand("%") | echo "Copied \"" . expand("%") . "\""
command! CopyPath :let @+=expand("%:h") . "/" | echo "Copied \"" . expand("%:h") . "/\""

" }}}

" Mappings {{{

"Do not use Ex-mode, open command-line window instead
noremap <silent> Q q:

" Better QWERTZ support
map <silent> ö [
map <silent> ä ]
map <silent> Ö {
map <silent> Ä }
map <silent> ü <c-]>

" clear last search pattern
map <silent> <leader>x :let @/ = ""<CR>

" }}}

" Filetype specifics {{{
augroup FILETYPE_CONF
  autocmd!

  " OpenGL syntax settings
  au BufNewFile,BufRead,BufEnter *.frag,*.vert,*.fp,*.glsl setf glsl
  " ROS launch files
  au BufNewFile,BufRead,BufEnter *.launch setf xml
  au BufNewFile,BufRead,BufEnter *.test setf xml

  " Makefiles require tabs
  au FileType make setlocal noexpandtab
  " Yamls default autoindent sucks
  au FileType yaml setlocal indentkeys-=0# indentkeys-=<:>
  "Latex
  au FileType tex setlocal spell
  "Vimwiki
  au FileType vimwiki setlocal nowrap

augroup END
" }}}
