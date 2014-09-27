set nocompatible
filetype off

if has('vim_starting')
	" neobundle
	set runtimepath+=$HOME/.vim/bundle/neobundle.vim/
	call neobundle#rc(expand('$HOME/.vim/bundle'))
endif

NeoBundleFetch 'Shougo/neobundle.vim'

"---------------------------"
" plugin
"---------------------------"

" edit
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'vim-scripts/AutoClose'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'LeafCage/yankround.vim'

" completion
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'

" searching/moving
NeoBundle 'rhysd/clever-f.vim'
NeoBundle 'fuenor/qfixgrep'
NeoBundle 'thinca/vim-qfreplace'

" programing
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'pangloss/vim-javascript'

" syntax
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'scrooloose/syntastic'

" utility
NeoBundle 'Shougo/vimproc', {
  \ 'build' : {
  \   'mac' : 'make -f make_mac.mak',
  \   'unix' : 'make -f make_unix.mak',
  \   },
  \ }
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'bling/vim-airline'
NeoBundle 'vim-scripts/sudo.vim'

" color schema
NeoBundle 'w0ng/vim-hybrid'

" unite
NeoBundle 'Shougo/unite.vim'
NeoBundle 'sgur/unite-qf'

" file explorer
NeoBundle 'scrooloose/nerdtree'

NeoBundleCheck

filetype plugin on

"---------------------------"
" color
"---------------------------"

set t_Co=256
syntax enable
set background=dark
colorscheme hybrid

"---------------------------
" basic
"---------------------------

set autoread " automaticaly reload file who chaged outside
set nobackup " not create backup file
set noswapfile " not create swap file
set noundofile
set showcmd
set showmode
set modeline
set showtabline=2 " 常にタブを表示
set clipboard=unnamed,autoselect " use os clipboard

"---------------------------
" appearance
"---------------------------

set showmatch
set number " line number

" コマンド実行中は再描画しない
set lazyredraw
" 高速ターミナル接続を行う
set ttyfast

"---------------------------
" indent
"---------------------------

set autoindent
set smartindent
set tabstop=4 " tabstop
set shiftwidth=4 " タブを挿入するときの幅
set expandtab " convert harf space

"---------------------------
" editing
"---------------------------

set noimdisable
set iminsert=0 imsearch=0
set noimcmdline
inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>

function! s:remove_dust()
    let cursor = getpos(".")
    %s/\s\+$//ge
    call setpos(".", cursor)
    unlet cursor
endfunction
autocmd BufWritePre * call <SID>remove_dust()
"---------------------------
" move
"---------------------------

" moving each window like eamcs.
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

"---------------------------
" completion
"---------------------------

" NeoComplCache
let g:neocomplcache_enable_at_startup = 1 " Use neocomplcache.
let g:neocomplcache_enable_smart_case = 1 " Use smartcase.
let g:neocomplcache_enable_camel_case_completion = 1 " Use camel case completion.
let g:neocomplcache_enable_underbar_completion = 1 " Use underbar completion.
set completeopt=menuone " 補完ウィンドウの設定

" tabで補完候補の選択を行う
inoremap <expr><TAB> pumvisible() ? "\<Down>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<Up>" : "\<S-TAB>"

" NeoSnippet
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

"---------------------------
" plugin
"---------------------------

" syntastic
let g:syntastic_mode_map = { 'mode': 'active',
  \ 'active_filetypes': ['javascript'],
  \ 'passive_filetypes': ['html'] }
let g:syntastic_auto_loc_list = 1
let g:syntastic_javascript_checkers = ['jshint']
" let g:syntastic_javascript_jshint_conf = '$HOME/.jshintrc'

" NERD Commenter
let NERDSpaceDelims = 1
let g:NERDTreeShowBookmarks = 1
nmap <C-C> <Plug>NERDCommenterToggle
vmap <C-C> <Plug>NERDCommenterToggle

" NERD Tree
map <silent> <C-e> :NERDTreeToggle<CR>

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" unite
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> ,ut :<C-u>Unite tab<CR>
nnoremap <silent> ,uq :<C-u>Unite qf<CR>
nnoremap <silent> ,ul :<C-u>Unite locate<CR>

call unite#custom#default_action('directory' , 'vimfiler')

" Vim AirLine
let g:airline_theme = 'bubblegum'

" Clever-f
let g:clever_f_fix_key_direction = 1
let g:clever_f_smart_case = 1

" Don't use preview at QuickFix
let QFix_PreviewEnable = 0

" yankround
let g:yankround_max_history = 30

nmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)

" if yankround is not active, ctrlp is available
nnoremap <silent><SID>(ctrlp) :<C-u>CtrlP<CR>
nmap <expr><C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "<SID>(ctrlp)"
