" vim: foldmethod=marker

" Helper functions {{{

function! s:hasPlugin(name)
  return has_key(g:plugs, a:name)
endfunction

function! s:hasItem(list, id, ...)
  let key = 'id'
  if a:0 == 1
    let key = a:1
  endif
  for item in a:list
    if item[key] == a:id
      return v:true
    endif
  endfor
  return v:false
endfunction

function! s:getItem(list, id, ...)
  let key = 'id'
  if a:0 == 1
    let key = a:1
  endif
  for item in a:list
    if item[key] == a:id
      return item
    endif
  endfor
  return v:false
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

if !filereadable('/usr/share/vim/vimfiles/plugin/fzf.vim')
  Plug 'junegunn/fzf', { 'do': { -> fzf#install()} }
endif
Plug 'junegunn/fzf.vim'

Plug 'morhetz/gruvbox'
Plug 'sheerun/vim-polyglot'
Plug 'vimwiki/vimwiki'
Plug 'metakirby5/codi.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar', { 'on': ['TagbarToggle', 'TagbarOpen'] }
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'lervag/vimtex'
Plug 'vim-airline/vim-airline'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

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
  hi Folded guibg=#282828
  augroup SETHIGHLIGHT
    autocmd!
    " same background as terminal -> transparency is still applied
    autocmd VimEnter * hi Normal guibg=#060607
    autocmd VimEnter * hi CursorLineNr guibg=#282828
    autocmd VimEnter * hi LineNr guibg=#282828
    autocmd VimEnter * hi Folded guibg=#282828
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

" surround {{{
if s:hasPlugin('vim-surround')

nmap s ys
xmap s S

endif
" }}}

" CamelCaseMotion {{{
if s:hasPlugin('CamelCaseMotion')
let g:camelcasemotion_key = '<leader>'
endif
" }}}

" FZF {{{
if s:hasPlugin('fzf.vim')

let g:fzf_command_prefix = 'Fzf'
nnoremap <silent> <C-F> :FzfFiles<CR>
nnoremap <silent> <C-B> :FzfBuffers<CR>
nnoremap <silent><expr> <C-G> empty(tagfiles())? ":FzfBTags\<CR>" : ":FzfTags\<CR>"
command! -nargs=* Files FzfFiles <args>
command! -nargs=* Rg FzfRg <args>

function! s:fzfFromItemList(list)
  let ids = []
  for item in a:list
    if item.req()
      call add(ids, item.id)
    endif
  endfor
  call fzf#run(fzf#wrap({'source': ids, 'sink': {id -> s:getItem(a:list, id).cmd()}}))
endfunction

endif
" }}}

" polyglot {{{
if s:hasPlugin('vim-polyglot')

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
let g:vimwiki_key_mappings = { 'global': 0 }

endif
" }}}

" gitgutter {{{
if s:hasPlugin('vim-gitgutter')

set signcolumn=yes
set updatetime=500

let g:gitgutter_map_keys = 1
command! StageHunk GitGutterStageHunk
command! StageUndo GitGutterUndoHunk

endif
" }}}

" gutentags {{{
if s:hasPlugin('vim-gutentags')

let g:gutentags_cache_dir="~/.cache/tagfiles"
let g:gutentags_define_advanced_commands=1

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

" coc.nvim {{{
if s:hasPlugin('coc.nvim')

set shortmess+=c

inoremap <silent><expr> <c-space> coc#refresh()
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

if s:hasPlugin('fzf.vim')
  let g:custom_action_list = [
   \ { 'id': 'quickfix', 'req': {-> !empty(CocAction('quickfixes'))}, 'cmd': {-> CocAction('doQuickfix') } },
   \ { 'id': 'switch header/source', 'req': {-> s:hasItem(CocAction('commands'), 'clangd.switchSourceHeader')}, 'cmd': {-> CocAction('runCommand', 'clangd.switchSourceHeader')}},
   \ { 'id': 'rename symbol', 'req': {-> CocHasProvider('rename')}, 'cmd': {-> CocAction('rename') } },
   \ { 'id': 'open link', 'req': {-> CocHasProvider('documentLink')},'cmd': {-> CocAction('openLink') } },
   \ { 'id': 'go to reference', 'req': {-> CocHasProvider('reference')}, 'cmd': {-> CocAction('jumpReferences') } },
   \ { 'id': 'go to declaration', 'req': {-> CocHasProvider('declaration')}, 'cmd': {-> CocAction('jumpDeclaration') } },
   \ { 'id': 'go to implementation', 'req': {-> CocHasProvider('implementation')}, 'cmd': {-> CocAction('jumpImplementation') } },
   \ { 'id': 'go to type definition', 'req': {-> CocHasProvider('typeDefinition')}, 'cmd': {-> CocAction('jumpTypeDefinition') } },
   \ { 'id': 'go to definition', 'req': {-> CocHasProvider('definition')}, 'cmd': {-> CocAction('jumpDefinition') } },
   \ { 'id': 'format buffer', 'req': {-> CocHasProvider('format')}, 'cmd': {-> CocAction('format') } },
   \ { 'id': 'fold buffer', 'req': {-> CocHasProvider('foldingRange')}, 'cmd': {-> CocAction('fold') } },
   \ { 'id': 'list diagnostics', 'req': {-> !empty(CocAction('diagnosticList'))}, 'cmd': {-> execute("CocList diagnostics")} },
   \ { 'id': 'restart coc', 'req': {-> v:true}, 'cmd': {-> execute("CocRestart")} },
   \]

  map <leader>l :call <SID>fzfFromItemList(g:custom_action_list)<CR>
endif

let g:coc_snippet_next = '<C-l>'
let g:coc_snippet_prev = '<C-h>'
"c-h is in conflict with auto mapping, add other mappings though:
let g:coc_selectmode_mapping = 0
snoremap <silent> <BS> <c-g>c
snoremap <silent> <DEL> <c-g>c
snoremap <c-r> <c-g>"_c<c-r>

augroup COC
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
endif
" }}}

