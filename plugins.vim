" vim: foldmethod=marker

" Helper functions {{{

function! s:hasPlugin(name)
  return has_key(g:plugs, a:name)
endfunction

"}}}

" Plugins {{{

"Install vim-plug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-plug'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/argtextobj.vim'
Plug 'bkad/CamelCaseMotion'

Plug 'junegunn/fzf', { 'do': { -> fzf#install()} }
Plug 'junegunn/fzf.vim'

Plug 'morhetz/gruvbox'
Plug 'sheerun/polyglot'
Plug 'vimwiki/vimwiki'

Plug 'airblade/vim-gitgutter'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar', { 'on': ['TagbarToggle', 'TagbarOpen'] }
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'lervag/vimtex'
Plug 'vim-airline/vim-airline'

call plug#end()

"}}}

" Colorscheme {{{
if s:hasPlugin('gruvbox')

function! s:lightBackground()
  set background=light
  hi Normal guibg=#fefced
  hi CursorLineNr guibg=#fbf1c7
  hi LineNr guibg=#fbf1c7
  augroup SETHIGHLIGHT
    autocmd!
    autocmd VimEnter * hi Normal guibg=#fefced
    autocmd VimEnter * hi CursorLineNr guibg=#fbf1c7
    autocmd VimEnter * hi LineNr guibg=#fbf1c7
  augroup END
endfunction

function! s:darkBackground()
  set background=dark
  " same background as terminal -> transparency is still applied
  hi Normal guibg=#060607
  hi CursorLineNr guibg=#282828
  hi LineNr guibg=#282828
  augroup SETHIGHLIGHT
    autocmd!
    " same background as terminal -> transparency is still applied
    autocmd VimEnter * hi Normal guibg=#060607
    autocmd VimEnter * hi CursorLineNr guibg=#282828
    autocmd VimEnter * hi LineNr guibg=#282828
  augroup END
endfunction

function! s:opaqueBackground()
  set background=dark
  hi Normal guibg=#151413
  hi CursorLineNr guibg=#282828
  hi LineNr guibg=#282828
  augroup SETHIGHLIGHT
    autocmd!
    autocmd VimEnter * hi Normal guibg=#151413
    autocmd VimEnter * hi CursorLineNr guibg=#282828
    autocmd VimEnter * hi LineNr guibg=#282828
  augroup END
endfunction

command! ColorDark call s:darkBackground()
command! ColorLight call s:lightBackground()
command! ColorOpaque call s:opaqueBackground()

if !has("gui_running")
  set termguicolors
  let g:gruvbox_italic=1
endif
colorscheme gruvbox
let g:airline_theme='gruvbox'
ColorDark

endif
" }}}

" FZF {{{
if s:hasPlugin('fzf.vim')

nnoremap <silent> <leader>E :Files<CR>
nnoremap <silent> <leader>e :Buffers<CR>
nnoremap <silent> <leader>f :BLines<CR>
nnoremap <silent> <leader>c :Commands<CR>
nnoremap <leader>F :Rg<space>

endif
" }}}

" polyglot {{{
if s:hasPlugin('polyglot')

let g:polyglot_disabled = [
  \ 'c++11',
  \ 'c/c++',
  \ 'python-compiler',
  \ 'latex'
  \]

endif
" }}}

" vimwiki {{{
if s:hasPlugin('vimwiki')

let g:vimwiki_use_mouse = 1

endif
" }}}

" gitgutter {{{
if s:hasPlugin('vim-gitgutter')

set signcolumn=yes
set updatetime=500

let g:gitgutter_map_keys = 1

endif
" }}}

" gutentags {{{
if s:hasPlugin('vim-gutentags')

let g:gutentags_cache_dir="~/.cache/tagfiles"

endif
" }}}

" tagbar {{{
if s:hasPlugin('tagbar')

command! Tb :TagbarToggle
nnoremap <silent> <leader>t :TagbarOpen j<CR>

endif
" }}}

" nerdtree {{{
if s:hasPlugin('nerdtree')

command! Nt :NERDTreeToggle
command! Ntf :NERDTreeFind
let NERDTreeIgnore=['\.pyc$[[file]]', '^\.git$[[dir]]', '\.o$[[file]]']

endif
" }}}

" vimtex {{{
if s:hasPlugin('vimtex')

function s:startRemoteServer()
  if empty(v:servername) && exists('*remote_startserver')
    call remote_startserver('VIM')
  endif
endfunction()

let g:vimtex_complete_bib = {'simple': 1}
let g:vimtex_quickfix_latexlog = {
      \ 'overfull' : 0,
      \ 'underfull' : 0,
      \ 'packages' : {
      \   'default' : 0,
      \ },
      \}
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_autoclose_after_keystrokes = 5
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
let g:vimtex_format_enabled = 1
"Note: To perform a backward (or inverse) search in Okular, you do 'shift + click'.
"If latexmk fails to compile, try running `latexmk -pdf <file>` once
let g:vimtex_imaps_leader = 'jj'
"FIXME they fucked it
"call deoplete#custom#var('omni', 'input_patterns', {
"        \ 'tex': g:vimtex#re#deoplete
"        \})
augroup VIMTEX
  au!
  au  FileType tex call s:startRemoteServer()
augroup END

endif
" }}}

" airline {{{
if s:hasPlugin('vim-airline')

set laststatus=2
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline#extensions#tabline#enabled = 1
let g:airline_left_alt_sep = '|'
let g:airline_left_sep = ' '
let g:airline_right_alt_sep = '|'
let g:airline_right_sep = ' '
let g:airline_symbols.maxlinenr = ''
set ttimeoutlen=10

endif
" }}}

