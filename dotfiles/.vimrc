" Indentation
set tabstop=2
set shiftwidth=2
set expandtab
filetype indent plugin on
set autoindent

" Text wrapping
autocmd BufNewFile,BufRead *.txt set tw=80
au BufRead,BufNewFile *.md setlocal textwidth=80
autocmd BufNewFile,BufRead *.txt set formatoptions+=nt

" Line numbers
set number

" Spell checking
autocmd BufRead *.txt setlocal spell spelllang=en_us
autocmd BufRead *.md setlocal spell spelllang=en_us

" Custom undo directory
set undodir=~/.vim/undo
set undofile

" Syntax highlighting
syntax enable

" File tab completion
set wildmode=longest,list,full
set wildmenu
set wildignorecase

" Airline theme
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'

" Keys
let mapleader = ","
inoremap jj <Esc>
nnoremap <leader><leader> <c-^>
