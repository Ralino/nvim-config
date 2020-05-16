" vim: foldmethod=marker
" Base config with sane defaults
" should be kept compatible with vim, nvim and embedded nvim

" Settings {{{
set nocompatible

"FIXME consider using $XDG_CONFIG_HOME/nvim
set runtimepath^=~/.vim runtimepath+=~/.vim/after

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
set tildeop
if has("nvim")
  set inccommand=split
endif

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
set expandtab
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

"I am bad at typing
command! W :w
command! Wq :wq
command! WQ :wq
command! Q :q
command! Qa :qa
command! QA :qa

if !has("nvim")
  command! SudoW :w !sudo tee % > /dev/null
else
  function! s:runInteractive(cmd)
    let buf = nvim_create_buf(v:false, v:true)
    let window_opts = {
          \ 'relative': 'editor',
          \ 'width': 40, 'height': 3,
          \ 'row': (&lines / 2 - 2), 'col': (&columns / 2 - 15),
          \ 'style': 'minimal'
          \ }
    noautocmd call nvim_open_win(buf, v:true, window_opts)
    call termopen(a:cmd)
    normal i
  endfunction

  function! s:nvimSudoW()
    let tmpfile = tempname()
    exe "write! >> " . tmpfile
    exe "autocmd BufEnter * ++once edit! | call jobstart(['rm','".tmpfile."'])"
    call s:runInteractive("sudo sh -c 'cat " . tmpfile . " > " . expand("%") . "'")
  endfunction

  command! SudoW call <SID>nvimSudoW()
endif

command! CopyFilename :let @+=expand("%") | echo "Copied \"" . expand("%") . "\""
command! CopyPath :let @+=expand("%:h") . "/" | echo "Copied \"" . expand("%:h") . "/\""

command! Retrail :%s/\s\+$//e | let @/ = ""

command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis

" }}}

" Mappings {{{

" Use <C-S> for window commands to solve conflict with terminal <C-W>
map <C-S> <C-W>
imap <C-S> <C-O><C-W>
tnoremap <C-S> <C-\><C-N><C-W>

tnoremap <C-N> <C-\><C-N>

"buffer/tab switching
noremap gb :bnext<CR>
noremap gB :bprevious<CR>
if has("nvim")
  noremap <silent><expr>  <C-Q> len(nvim_list_tabpages()) == 1 ? ":bnext\<CR>" : ":tabnext\<CR>"
  tnoremap <silent><expr> <C-Q> len(nvim_list_tabpages()) == 1 ? "<C-\><C-N>:bnext\<CR>" : "<C-\><C-N>:tabnext\<CR>"
else
  noremap <silent> <C-Q> :bnext<CR>
endif

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

" completion menu mappings
inoremap <silent><expr> <Tab> pumvisible() ? "\<Down>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<Up>" : "\<S-Tab>"
inoremap <silent><expr> <C-J> pumvisible() ? "\<C-N>" : "\<C-J>"
inoremap <silent><expr> <C-K> pumvisible() ? "\<C-P>" : "\<C-K>"
inoremap <silent><expr> <C-L> pumvisible() ? "\<C-Y>" : "\<C-L>"

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
  "Comments in json
  au FileType json syntax match Comment +\/\/.\+$+

augroup END
" }}}
