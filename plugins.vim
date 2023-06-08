" vim: foldmethod=marker

" Helper functions {{{

function! s:hasPlugin(name)
  return has_key(g:plugs, a:name) && isdirectory(g:plugs[a:name].dir)
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

let main_runtime_dir = split(&runtimepath, ',')[0]

"}}}

" polyglot {{{

" needs to be defined before it is loaded
let g:polyglot_disabled = [
  \ 'c++11',
  \ 'c/c++',
  \ 'python-compiler',
  \ 'latex'
  \]

let g:vue_pre_processors = 'detect_on_enter'

" }}}

" Plugins {{{

"Install vim-plug if not already installed
if empty(glob(main_runtime_dir . '/autoload/plug.vim'))
  execute 'silent !curl -fLo ' . main_runtime_dir . '/autoload/plug.vim --create-dirs '
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(main_runtime_dir . '/plugged')

Plug 'junegunn/vim-plug'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
Plug 'vim-scripts/argtextobj.vim'
Plug 'bkad/CamelCaseMotion'
if has('nvim-0.7')
  Plug 'ggandor/leap.nvim'
endif

if !executable('fzf')
  Plug 'junegunn/fzf', { 'do': { -> fzf#install()} }
else
  Plug 'junegunn/fzf'
endif
Plug 'junegunn/fzf.vim'

Plug 'jesseleite/vim-agriculture'

Plug 'morhetz/gruvbox'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
"FIXME potentially breaks fugitive: https://github.com/tpope/vim-fugitive/issues/1624
"Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'vim-airline/vim-airline'

if executable('ctags')
  " Plug 'ludovicchabant/vim-gutentags' FIXME check performance issues
  Plug 'majutsushi/tagbar', { 'on': ['TagbarToggle', 'TagbarOpen'] }
endif

if !has("win32")
  Plug 'vimwiki/vimwiki'
  Plug 'lervag/vimtex'
endif

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

"nnoremap s ys
xnoremap s S

endif
" }}}

" CamelCaseMotion {{{
if s:hasPlugin('CamelCaseMotion')
let g:camelcasemotion_key = '<leader>'
endif
" }}}

" leap {{{
if s:hasPlugin('leap.nvim')

lua require('leap').add_default_mappings()
lua require('leap').opts.safe_labels = { "s", "f", "n", "u", "t",
      \ "S", "F", "N", "L", "H", "M", "U", "G", "T", "Z" }

endif
" }}}

" FZF {{{
if s:hasPlugin('fzf.vim')

let g:fzf_command_prefix = 'Fzf'
let g:fzf_files_options = $FZF_CTRL_T_OPTS
nnoremap <silent> <C-F> :FzfFiles<CR>
nnoremap <silent> <C-B> :FzfBuffers<CR>
nnoremap <silent><expr> <C-G> empty(tagfiles())? ":FzfBTags\<CR>" : ":FzfTags\<CR>"
command! -nargs=* -complete=dir Files FzfFiles <args>
command! -nargs=* Rg FzfRg <args>

nnoremap <leader>f :Files<space>

function! s:gfWithFallback()
  let previous_fzf_cmd = $FZF_DEFAULT_COMMAND
  try
    normal! gf
  catch /^Vim\%((\a\+)\)\=:E447:/
    let $FZF_DEFAULT_COMMAND = 'fd --hidden --follow --full-path ' . shellescape(expand('<cfile>')) . ' 2> /dev/null'
    "FIXME works, but is not really nice
    FzfFiles
  finally
    let $FZF_DEFAULT_COMMAND = previous_fzf_cmd
  endtry
endfunction
nnoremap gf :call <SID>gfWithFallback()<CR>

function! s:fzfFromItemList(list)
  let ids = []
  let longest_item = 1
  for item in a:list
    if item.req()
      call add(ids, item.id)
      if (strlen(item.id) > longest_item)
        let longest_item = strlen(item.id)
      endif
    endif
  endfor
  let window_dict = { 'width': min([longest_item + 8, 130]), 'height': min([len(ids) + 4, 35]) }
  call fzf#run(fzf#wrap({'window': window_dict, 'source': ids, 'sink': {id -> s:getItem(a:list, id).cmd()}}))
endfunction

if has("win32")
  let g:fzf_preview_window = []
  let g:fzf_layout = { 'window': { 'width': 130, 'height': 35 } }
else
  let g:fzf_layout = { 'window': { 'width': 200, 'height': 35 } }
endif

endif
" }}}

" agriculture {{{
if s:hasPlugin('vim-agriculture')

nmap <leader>/ <Plug>RgRawSearch
vmap <leader>* y:let @" = shellescape(getreg('"'))<CR>:RgRaw -F -- <C-R>"<C-b><C-Right><C-Right>
nmap <leader>* yiw:let @" = shellescape(getreg('"'))<CR>:RgRaw -w -F -- <C-R>"<C-b><C-Right><C-Right><C-Right>

endif
" }}}

" vimwiki {{{
if s:hasPlugin('vimwiki')

let g:vimwiki_use_mouse = 1
let g:vimwiki_key_mappings = { 'global': 0 }

endif
" }}}

" fugitive {{{
if s:hasPlugin('vim-fugitive')

command! Gtree exe 'split | terminal' FugitivePrepare(['log', '--oneline', '--decorate', '--graph', '--all'])
command! GTree  Gtree

endif
" }}}

" gitgutter {{{
if s:hasPlugin('vim-gitgutter')

set signcolumn=yes
set updatetime=400
let g:gitgutter_max_signs=2000

endif
" }}}

" gutentags {{{
if s:hasPlugin('vim-gutentags')

if has("nvim")
  let g:gutentags_cache_dir=stdpath('cache') . "/gutentags"
else
  let g:gutentags_cache_dir="~/.cache/gutentags"
endif

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

let g:tex_flavor = 'latex'
let g:vimtex_complete_bib = {'simple': 1}
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_autoclose_after_keystrokes = 5
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
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
let g:airline_section_z = '%#__accent_bold#%{g:airline_symbols.linenr}%l%#__restore__#%#__accent_bold#/%L%{g:airline_symbols.maxlinenr}%#__restore__#%#__accent_bold#%{g:airline_symbols.colnr}%v%#__restore__#'
let g:airline_symbols.linenr = ''
let g:airline_symbols.maxlinenr = ''

endif
" }}}

" coc.nvim {{{
if s:hasPlugin('coc.nvim')

set shortmess+=c

inoremap <silent><expr> <c-space> coc#refresh()
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

function! s:gdWithFallback()
  if CocHasProvider('definition')
    call CocAction('jumpDefinition')
  else
    normal! gd
  endif
endfunction

function! s:showDocumentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <silent> gd :call <SID>gdWithFallback()<CR>
nnoremap <silent> K :call <SID>showDocumentation()<CR>

" completion menu mappings for cocs popup menu
inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#next(0) : "\<Tab>"
inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(0) : "\<S-Tab>"
inoremap <silent><expr> <C-J> coc#pum#visible() ? coc#pum#next(1) : "\<C-J>"
inoremap <silent><expr> <C-K> coc#pum#visible() ? coc#pum#prev(1) : "\<C-K>"
inoremap <silent><expr> <C-L> coc#pum#visible() ? coc#pum#confirm() : "\<C-L>"
highlight! link CocMenuSel PMenuSel

if s:hasPlugin('fzf.vim')
  let g:custom_action_list = [
   \ { 'id': 'quickfix', 'req': {-> !empty(CocAction('quickfixes'))}, 'cmd': {-> CocAction('doQuickfix') } },
   \ { 'id': 'switch header/source', 'req': {-> s:hasItem(CocAction('commands'), 'clangd.switchSourceHeader')}, 'cmd': {-> CocAction('runCommand', 'clangd.switchSourceHeader')}},
   \ { 'id': 'open link', 'req': {-> CocHasProvider('documentLink')},'cmd': {-> CocAction('openLink') } },
   \ { 'id': 'go to reference', 'req': {-> CocHasProvider('reference')}, 'cmd': {-> CocAction('jumpReferences') } },
   \ { 'id': 'go to declaration', 'req': {-> CocHasProvider('declaration')}, 'cmd': {-> CocAction('jumpDeclaration') } },
   \ { 'id': 'go to implementation', 'req': {-> CocHasProvider('implementation')}, 'cmd': {-> CocAction('jumpImplementation') } },
   \ { 'id': 'go to type definition', 'req': {-> CocHasProvider('typeDefinition')}, 'cmd': {-> CocAction('jumpTypeDefinition') } },
   \ { 'id': 'go to definition', 'req': {-> CocHasProvider('definition')}, 'cmd': {-> CocAction('jumpDefinition') } },
   \ { 'id': 'format buffer', 'req': {-> CocHasProvider('format')}, 'cmd': {-> CocAction('format') } },
   \ { 'id': 'fold buffer', 'req': {-> CocHasProvider('foldingRange')}, 'cmd': {-> CocAction('fold') } },
   \ { 'id': 'list diagnostics', 'req': {-> !empty(CocAction('diagnosticList'))}, 'cmd': {-> execute("CocList diagnostics")} },
   \ { 'id': 'disable diagnostics', 'req': {-> !exists("b:coc_diagnostic_disable")}, 'cmd': {-> execute("let b:coc_diagnostic_disable=1 | CocRestart")} },
   \ { 'id': 'enable diagnostics', 'req': {-> exists("b:coc_diagnostic_disable")}, 'cmd': {-> execute("unlet b:coc_diagnostic_disable | CocRestart")} },
   \ { 'id': 'restart coc', 'req': {-> v:true}, 'cmd': {-> execute("CocRestart")} },
   \]

  map <leader>l :call <SID>fzfFromItemList(g:custom_action_list)<CR>
  sunmap <leader>l
endif

" inlay hints
hi CocInlayHint guifg=#83a598 guibg=NONE gui=italic

let g:coc_snippet_next = '<C-n>'
let g:coc_snippet_prev = '<C-p>'
"c-h is in conflict with auto mapping, add other mappings though:
let g:coc_selectmode_mapping = 0
snoremap <silent> <BS> <c-g>c
snoremap <silent> <DEL> <c-g>c
snoremap <c-r> <c-g>"_c<c-r>

nnoremap <silent> <leader>c :CocListResume<CR>

" cannot call rename feature from fzfs list window
nnoremap <F2> <Plug>(coc-rename)
nnoremap <leader>r <Plug>(coc-rename)

xnoremap <leader>f <Plug>(coc-format-selected)

augroup COC
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

  "clangd mappings
  au FileType cpp nnoremap <silent> <c-tab> :call CocAction('runCommand', 'clangd.switchSourceHeader')<CR>
endif
" }}}

" termdebug {{{
if has("nvim")

packadd termdebug

nnoremap <F5> :Continue<CR>
nnoremap <F6> :Step<CR>
nnoremap <F7> :Over<CR>
nnoremap <F8> :Finish<CR>

endif
" }}}
