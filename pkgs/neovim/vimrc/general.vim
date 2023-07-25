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

" set filetype to react for jsx and tsx, needed by coc-tsserver
augroup ReactFiletypes
  autocmd!
  autocmd BufRead,BufNewFile *.jsx set filetype=javascriptreact
  autocmd BufRead,BufNewFile *.tsx set filetype=typescriptreact
augroup END

" coc
set signcolumn=yes
set updatetime=300
" use enter to confirm completion
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
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
" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
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

" show actions for the current cursor
nmap <leader>ac  <Plug>(coc-codeaction-cursor)

" show actions for the current line
nmap <leader>al  <Plug>(coc-codeaction)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Open diagnostics window
nmap <silent> gi <Plug>(coc-diagnostic-info)

lua << EOF
require('telescope').setup{ defaults = { file_ignore_patterns = {".git"} } }
EOF
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files({ hidden = true })<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep({ additional_args = function () return { '--ignore-case', '--hidden' } end })<cr>

set nofoldenable

" disable mouse
set mouse=

