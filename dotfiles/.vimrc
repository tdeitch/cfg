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

" list mode
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣

" Spell checking
set spelllang=en_us
set spell
autocmd FileType help setlocal nospell

" Custom undo directory
set undodir=~/.vim/undo
set undofile

" Syntax highlighting
syntax enable

" File tab completion
set wildmode=longest,list,full
set wildmenu
set wildignorecase

" Omni completion
filetype plugin on
autocmd Filetype *
  \ if &omnifunc == "" |
  \ setlocal omnifunc=syntaxcomplete#Complete |
  \ endif

" Colors
set background=light
let g:airline_theme='seagull'

" Keys
let mapleader = ","
nnoremap <leader><leader> <c-^>

" Mouse
set mouse=a
