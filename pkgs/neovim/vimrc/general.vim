scriptencoding utf-8

set nocompatible
filetype off

syntax enable
let base16colorspace=256
set termguicolors
colorscheme base16-default-dark

let g:python_host_skip_check = 1

set enc=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf8,prc
set guifont=Monaco:h11
set guifontwide=NSimsun:h12

set number
set relativenumber
set ruler

set list
set listchars=nbsp:␠,tab:→\ ,trail:·,precedes:⇐,extends:⇒

set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

set backspace=2

set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
set statusline+=%#warningmsg#
set statusline+=%*

set completeopt-=preview

set cmdheight=2
let g:echodoc_enable_at_startup = 1

map <silent><space> :let @/=""<CR>
set hlsearch
set incsearch

set showcmd

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_max_depth = 40
let g:ctrlp_max_files = 20000
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|.git\/\|dist\/\|target\/\|build\/\|test_output\/'
let g:ctrlp_show_hidden = 1

set noswapfile

set colorcolumn=120
set cursorline
set cursorcolumn

" Gneral conceal settings
set conceallevel=1

" vim-javascript plugin settings
let g:javascript_conceal_function = "λ"
let g:javascript_conceal_arrow_function = "λ"

let g:vim_markdown_folding_disabled = 1

inoremap jj <esc>


" coc
" ctrl space trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
" use `:OR` for organize import of current cursor
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" gd - go to definition of word under cursor
nmap <silent> gd <Plug>(coc-definition)
" gtd - go to type definition
nmap <silent> gtd <Plug>(coc-type-definition)
" gi - go to implementation
nmap <silent> gi <Plug>(coc-implementation)
" gr - find references
nmap <silent> gr <Plug>(coc-references)
" gh - get hint on whatever's under the cursor
nnoremap <silent> gh :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" list commands available in tsserver (and others)
nnoremap <silent> <leader>cc  :<C-u>CocList commands<cr>

" restart when tsserver gets wonky
" leader === backslash
nnoremap <silent> <leader>cR  :<C-u>CocRestart<CR>

" view all errors
nnoremap <silent> <leader>cl  :<C-u>CocList locationlist<CR>

" rename the current word in the cursor
nmap <leader>cr  <Plug>(coc-rename)
