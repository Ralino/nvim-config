" vim: foldmethod=marker
" Base config with sane defaults
" should be kept compatible with vim, nvim and embedded nvim

" Settings {{{
set nocompatible

if !has("nvim")
  "$XDG_CONFIG_HOME/nvim for nvim (default)
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
endif

filetype plugin indent on
syntax on

set title
set ruler
set showcmd
set incsearch
set smartcase
" hint: use \C anywhere in a search term to force case sensitivity
set ignorecase
set nolangremap
set autoindent
set backspace=indent,eol,start
set mouse=a
set number
set relativenumber
set hidden
if has("nvim")
  set inccommand=split
endif

set belloff=all
set vb
set t_vb=

set undofile
set backupskip+=/dev/shm/*
if !has("nvim")
  "swap files
  set dir^=~/.vim/swap,~/.vim/tmp
  set undodir^=~/.vim/tmp
endif
augroup UNDOFILE
  au!
  au BufWritePre /tmp/* setlocal noundofile
  au BufWritePre /dev/shm/* setlocal noundofile
  au BufWritePre /tmp/* setlocal noswapfile
  au BufWritePre /dev/shm/* setlocal noswapfile
augroup END

if has("win32")
  "FIXME somehow vim on windows sometimes creates files which it does not have
  "permission to write to
  set nowritebackup
endif

set shiftwidth=2
set expandtab
set smarttab
set tabstop=4

set wrap
set scrolloff=2
set sidescrolloff=0
set sidescroll=1
set listchars=extends:►,precedes:◄

set wildmenu
set wildmode=longest:full,full

set foldmethod=marker

" use z= to choose a suggested fix
set spelllang=de,en_us
set spellsuggest=fast

let mapleader = " "
let maplocalleader = " "

set guioptions-=m guioptions-=T guioptions-=L

set scrollback=10000
augroup TERMSETTINGS
  autocmd!
  autocmd TermOpen * setlocal scrolloff=0
  autocmd TermOpen * setlocal nonumber
augroup END

augroup JUMPTOLASTCURSORPOS
  au!
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END

if has("win32")
  set guifont=Consolas:h12
  " BOMs are weird, strip it from fileencodings
  set fileencodings=utf-8,default,latin1
endif

" }}}

" Commands {{{

if has("win32")
  function! s:toggleShell(shell)
    if empty(a:shell) && &shell == 'powershell'
      " switch to default (cmd.exe)
      let &shell='cmd.exe'
      let &shellcmdflag='/s /c'
      let &shellquote=''
      let &shellxquote='"'
    else
      " switch to powershell
      let &shell='powershell'
      let &shellcmdflag='-NoProfile -c'
      let &shellquote='"'
      let &shellxquote=''
    endif
    echo "Using " . &shell . " as shell"
  endfunction

  command! SwitchShell call <SID>toggleShell('')
  "switch to powershell on startup
  "call <SID>toggleShell('powershell')

  command! Terminal :terminal powershell
endif

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
    startinsert
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

command! Retrail :%s/\s\+$//e | let @/ = "\\_$ cleared search"

command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis

command! FoldFunc set foldmethod=syntax | set foldcolumn=1

" quick terminal
function! s:quickTerminal(cmd)
  let cmd = a:cmd
  " FIXME allow win in all tabs
  if !exists("g:quick_term_win") || win_id2tabwin(g:quick_term_win) == [0,0]
    botright split
    resize 10
    set winfixheight
    let g:quick_term_win = win_getid()
    if empty(cmd)
      if has("win32")
        let cmd = 'powershell'
      else
        let cmd = &shell . " -i"
      endif
    endif
  else
    call win_gotoid(g:quick_term_win)
    startinsert
  endif
  if !empty(cmd)
    if has("nvim")
      execute 'terminal ' . cmd
    else
      execute 'terminal ++curwin ' . cmd
    endif
    startinsert
  endif
endfunction
command! -nargs=* -complete=shellcmd QuickTerm call <SID>quickTerminal(<q-args>)

" bufferize vim output
function! s:bufferize(cmd)
  let tmpfile = tempname() . '_vim'
  execute 'redir > ' . tmpfile
  execute 'silent ' . a:cmd
  redir END
  execute 'split ' . tmpfile
endfunction
command! -nargs=* -complete=command Bufferize call <SID>bufferize(<q-args>)
command! Messages call <SID>bufferize('messages') | silent g/^$/d | silent write | normal G

" }}}

" Mappings {{{

" Use <C-S> for window commands to solve conflict with terminal <C-W>
map <C-S> <C-W>
imap <C-S> <C-O><C-W>
tnoremap <C-S> <C-\><C-N><C-W>

tnoremap <C-N> <C-\><C-N>

"FIXME nvim occasionally hangs when using C-C in a terminal.
"Sort of reproducable when running a forked process in one terminal and
"pressing C-c in a another one
"neovim issue: https://github.com/neovim/neovim/issues/20726
"workaround: use C-X for cancelling programs in terminals
tnoremap <C-X> <C-C>

"use default clipboard mappings in visual and insert mode
nnoremap <C-C> "+yiw
xnoremap <C-C> "+y
inoremap <C-V> <C-O>"+P

"Quick terminal
noremap <silent> <C-Q> :QuickTerm<CR>
tnoremap <silent> <C-Q> <C-\><C-N><C-W>p

"buffer/tab switching
noremap gb :bnext<CR>
noremap gB :bprevious<CR>

"quick quickfix
nnoremap <leader>n :cnext<CR>
nnoremap <leader>N :cprev<CR>

"Do not use Ex-mode, open command-line window instead
noremap <silent> Q q:
sunmap Q

" Better QWERTZ support
set langmap=ö[,ä],Ö{,Ä}
map <silent> ü <c-]>
sunmap ü
"otherwise does not work with custom mappings
nmap ö [
nmap ä ]
omap ö [
omap ä ]
xmap ö [
xmap ä ]

" clear last search pattern, empty pattern for some reason is replaced by a different
" pattern in newer nvim and vim versions
map <silent> <leader>x :let @/ = "\\_$ cleared search"<CR>
sunmap <leader>x

" paste without overwriting register
xnoremap <leader>p "_dP

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
  au BufNewFile,BufRead,BufEnter *.frag,*.vert,*.fp,*.glsl,*.vsh,*.fsh,*.comp setf glsl
  " ROS launch files
  au BufNewFile,BufRead,BufEnter *.launch setf xml
  au BufNewFile,BufRead,BufEnter *.test setf xml
  " the fuck vim?
  au BufNewFile,BufRead,BufEnter *.tex setf tex
  " octave
  au BufNewFile,BufRead,BufEnter *.m setf octave
  " Qt resource files
  au BufNewFile,BufRead,BufEnter *.qrc setf xml

  " Makefiles require tabs
  au FileType make setlocal noexpandtab
  " Yamls default autoindent sucks
  au FileType yaml setlocal indentkeys-=0# indentkeys-=<:>
  " Latex
  au FileType tex setlocal spell
  au FileType tex setlocal textwidth=90
  " vimwiki
  au FileType vimwiki setlocal nowrap
  au FileType vimwiki setlocal textwidth=100
  " Comments in json
  au BufNewFile,BufRead,BufEnter *.json,.eslintrc setf jsonc | set syntax=json | syntax match Comment +\/\/.*$+
  " textwidth in plain text files
  au FileType text setlocal textwidth=100
  au FileType markdown setlocal textwidth=100
augroup END

function! MarkdownLevel()
  let h = matchstr(getline(v:lnum), '^#\+')
  if empty(h)
    return "="
  else
    return ">" . len(h)
  endif
endfunction
augroup MARKDOWN_FOLDING
  au BufEnter *.md setlocal foldexpr=MarkdownLevel()
  au BufEnter *.md setlocal foldmethod=expr
  au BufRead,BufNewFile *.md setlocal foldlevel=999
augroup END

" }}}
