syntax on
filetype plugin on
filetype indent on
"colorscheme desert

set encoding=utf-8
set list
set listchars=tab:>.,precedes:<,extends:>
set nowrap
set sidescroll=5
set ignorecase smartcase
set incsearch
set hlsearch
set wrapscan
set showmatch
set showcmd
set autoindent smartindent
set expandtab
set softtabstop=4 tabstop=4 shiftwidth=4
set wildmenu
set wildmode=longest,list
set hidden
set autoread
set ambiwidth=double

nnoremap j gj
nnoremap k gk

highlight ZenkakuSpace ctermbg=red
match ZenkakuSpace /\s\+$\|　/
