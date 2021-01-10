" **********************************************************************
" Basic Setup
" **********************************************************************
set undofile    " Enable undos
set swapfile    " Enable swapfiles
set notimeout   " Wait for keys forever because I'm slow

"" Encoding
set fileencoding=utf-8
set fileencodings=utf-8

"" Enable hidden buffers
set hidden

"" Searching
set ignorecase  " Ignore case when searching
set smartcase   " Do not ignore case when search upper case characters

" Tab settings
set expandtab   " expand tabs to spaces
set shiftwidth=4
set softtabstop=4

set scrolloff=5   " keep at minimum few lines from top and bottom when scrolling

" Strings ot use in list mode
set listchars=eol:$,tab:→–,trail:~,extends:>,precedes:<,nbsp:•

" Auto-reload files when changed outside of the editor
autocmd FocusGained * :checktime

" Language settings
set keymap=russian-jcukenwin
set iminsert=0 " default insert - english
set imsearch=0 " default search - english
set spelllang=ru_yo,en_us

" wildmode style
set wildmode=longest:full,full
set wildignore+=*/tmp/*,.git,*.o,*.obj,*.so,*.swp,*.zip,*.pyc,__pycache__,*.db,*.sqlite


" **********************************************************************
" Visual Settings
" **********************************************************************
syntax on
set number        " Show line numbers
set linebreak     " Break on word boundaries
set breakindent   " Indent wrapped lines
set showbreak=↪   " Visually prepend wrapped lines with symbol
set cpoptions+=$  " Put $ at the boundary of current replace
set title         " Set window title

" cross
set cursorcolumn

let no_buffers_menu=1

" Theme
set gfn=FiraCode\ Nerd\ Font\ Mono\ 12

if $COLORTERM == 'truecolor'
  set t_Co=256
  set t_8f=^[[38;2;%lu;%lu;%lum
  set t_8b=^[[48;2;%lu;%lu;%lum
endif

" **********************************************************************
" Abbreviations
" **********************************************************************
"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall


" **********************************************************************
" Commands
" **********************************************************************
"" remove trailing whitespaces
command! FixWhitespace :%s/\s\+$//e


" **********************************************************************
" Functions
" **********************************************************************

if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap
    set wm=2
    set textwidth=79
  endfunction
endif


" **********************************************************************
" Autocmd Rules
" **********************************************************************

"" The PC is fast enough, do syntax highlight syncing from start unless 200 lines
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=200
augroup END

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"" txt
augroup vimrc-wrapping
  autocmd!
  autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" Enable custom syntax highlight
augroup filetype
  au! BufRead,BufNewFile *.ino setfiletype cpp
  au! BufRead,BufNewFile *.xod* setfiletype json
augroup end

" Custom settings for file types
augroup filetype
  au! FileType cpp set sw=4 sts=4
augroup end


" **********************************************************************
" Mappings
" **********************************************************************
"" Map leader to...
let mapleader = " "
nmap <bslash> <space> " compat

" More natural behavior on auto-wrapped lines
nnoremap j gj
nnoremap k gk

"" Split
noremap <leader>h :<C-u>split<cr>
noremap <leader>v :<C-u>vsplit<cr>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<cr>

" terminal emulation
nnoremap <silent> <leader>sh :terminal<cr>
tnoremap <Esc> <C-\><C-n>

"" Opens an edit command with the path of the currently edited file filled in
noremap <leader>e :e <C-R>=expand("%:p:h") . "/" <cr>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <leader>te :tabe <C-R>=expand("%:p:h") . "/" <cr>

" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

" Copy whole buffer into clipboard
nnoremap YY m'gg"+yG''

" Copy current buffer's full fs path to clipboard
noremap <silent> <leader>yp :let @+=expand("%:p")<cr>

"" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Buffer nav
noremap <leader>q :bp<cr>
noremap <leader>w :bn<cr>

"" Close buffer with window
noremap <leader>d :bdelete<cr>

"" Clean search (highlight)
nnoremap <silent> <leader>h :noh<cr>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<cr>gv=gv
vnoremap K :m '<-2<cr>gv=gv

" Allow saving of files as sudo when I forgot to start vim using sudo
cmap w!! w !sudo tee > /dev/null %

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gp :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>

" **********************************************************************
" Convenience variables
" **********************************************************************
