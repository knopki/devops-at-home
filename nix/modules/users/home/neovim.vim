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

set wildignore+=*/tmp/*,.git,*.o,*.obj,*.so,*.swp,*.zip,*.pyc,__pycache__,*.db,*.sqlite


" **********************************************************************
" Visual Settings
" **********************************************************************
syntax on
set number        " Show line numbers
set linebreak     " Break on word boundaries
set cpoptions+=$  " Put $ at the boundary of current replace
set title         " Set window title

let no_buffers_menu=1

" Theme
set gfn=FuraCode\ Nerd\ Font\ Mono\ 12
if has("termguicolors")
  set termguicolors
endif
let g:one_allow_italics = 1
colorscheme one
if $COLORTERM == 'truecolor'
  set t_Co=256
  set t_8f=^[[38;2;%lu;%lu;%lum
  set t_8b=^[[48;2;%lu;%lu;%lum
endif

"" indentLine
let g:indentLine_enabled = 1
let g:indentLine_concealcursor = 0
let g:indentLine_char = '┆'
let g:indentLine_faster = 1

" vim-airline
if $TERM =~ '256color'
  let g:airline_powerline_fonts = 1
endif
let g:airline_theme='one'
let g:airline_highlighting_cache = 1
let g:airline_skip_empty_sections = 1
let g:airline_extensions = ['branch', 'tabline']
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1


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


"*****************************************************************************
"" Commands
"*****************************************************************************
" remove trailing whitespaces
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
  au! FileType html set sw=2 sts=2
  au! FileType javascript set sw=2 sts=2
  au! FileType json set sw=2 sts=2
  au! FileType yaml set sw=2 sts=2
  au! FileType php set expandtab sw=4 sts=8
augroup end


" **********************************************************************
" Mappings
" **********************************************************************
"" Map leader to...
let mapleader = " "
nmap <bslash> <space> " compat

"" Split
noremap <leader>h :<C-u>split<cr>
noremap <leader>v :<C-u>vsplit<cr>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<cr>

" terminal emulation
nnoremap <silent> <leader>sh :terminal<cr>

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

" noremap YY "+y<cr>
" noremap <leader>p "+gP<cr>
" noremap XX "+x<cr>

"" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Buffer nav
noremap <leader>q :bp<cr>
noremap <leader>w :bn<cr>

"" Close buffer
noremap <leader>d :Bdelete<cr>

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

"" NERDTree configuration
nnoremap <silent> <leader>n :NERDTreeToggle<cr>

"" fzf
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fgf :GFiles?!<CR>
nnoremap <leader>fb :Buffers<CR>
nmap <leader>fh :History:<CR>
nmap <leader>frg :Rg!<Space>
" TODO: snips
" TODO: Commits

" session management
nnoremap <leader>so :SLoad<CR>
nnoremap <leader>ss :SSave!<CR>
nnoremap <leader>sd :SDelete<CR>
nnoremap <leader>sc :SClose<CR>


" **********************************************************************
" Custom configs
" **********************************************************************

" -------------------------------------
" NERDTree
" -------------------------------------
let g:NERDTreeChDirMode = 2
let g:NERDTreeIgnore=['\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks = 1


" -------------------------------------
" fzf.vim
" -------------------------------------
" set wildmode=list:longest,list:full
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
if executable('rg')
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
endif


" -------------------------------------
" vim-startify
" -------------------------------------
let g:startify_bookmarks = ['~/dev/knopki/devops-at-home']
let g:startify_session_persistence = 1
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 1
let g:startify_session_sort = 0
let g:startify_custom_header = []
let g:startify_skip_list = ['COMMIT_MSG', '/nit/store/*']















" **********************************************************************
" Convenience variables
" **********************************************************************





"" nvim 0.4.2+ gui-only initializer
function! s:ui_enter()
  if get(v:event, "chan") == 1
    " do your gui setup
  endif
endfunction

au UIEnter * call s:ui_enter()
