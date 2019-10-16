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

if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
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
"augroup filetype
  "au! FileType cpp set sw=4 sts=4
"augroup end


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
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fgf :GFiles!?<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nmap     <silent> <leader>fh :History:<CR>
nnoremap <silent> <Leader>rg :Rg <C-R><C-W><CR>
nnoremap <silent> <Leader>RG :Rg <C-R><C-A><CR>
xnoremap <silent> <Leader>rg y:Rg <C-R>"<CR>
nnoremap <silent> <leader>fc :Commits<CR>
nnoremap <silent> <leader>fC :BCommits<CR>
nnoremap <silent> <leader>fs :Snippets<CR>


" session management
nnoremap <leader>so :SLoad<CR>
nnoremap <leader>ss :SSave!<CR>
nnoremap <leader>sd :SDelete<CR>
nnoremap <leader>sc :SClose<CR>

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
autocmd! FileType fzf
autocmd  FileType fzf set noshowmode noruler nonu

" floating windows
if has('nvim') && exists('&winblend') && &termguicolors
  set winblend=10

  hi NormalFloat guibg=None

  if stridx($FZF_DEFAULT_OPTS, '--border') == -1
    let $FZF_DEFAULT_OPTS .= ' --border --margin=0,2'
  endif

  function! FloatingFZF()
    let width = float2nr(&columns * 0.9)
    let height = float2nr(&lines * 0.6)
    let opts = { 'relative': 'editor',
              \ 'row': (&lines - height) / 2,
              \ 'col': (&columns - width) / 2,
              \ 'width': width,
              \ 'height': height }

    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
  endfunction

  let g:fzf_layout = { 'window': 'call FloatingFZF()' }
endif

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

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


" -------------------------------------
" ultisnips
" -------------------------------------
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsEditSplit="vertical"


" -------------------------------------
" Arguments movement and objects
" -------------------------------------
nnoremap <leader>< :SidewaysLeft<CR>
nnoremap <leader>> :SidewaysRight<CR>
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI


" -------------------------------------
" Context filetypes for NERDCommenter and more
" -------------------------------------
if !exists('g:context_filetype#same_filetypes')
  let g:context_filetype#filetypes = {}
endif
let g:context_filetype#filetypes.svelte =
\ [
\   {'filetype' : 'javascript', 'start' : '<script>', 'end' : '</script>'},
\   {
\     'filetype': 'typescript',
\     'start': '<script\%( [^>]*\)\? \%(ts\|lang="\%(ts\|typescript\)"\)\%( [^>]*\)\?>',
\     'end': '</script>',
\   },
\   {'filetype' : 'css', 'start' : '<style \?.*>', 'end' : '</style>'},
\ ]


" -------------------------------------
" NERDCommenter
" -------------------------------------
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1
let g:NERDCommentEmpryLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1
let g:ft = ''
fu! NERDCommenter_before()
  if (&ft == 'html') || (&ft == 'svelte') || (&ft == 'vue')
    let g:ft = &ft
    let cfts = context_filetype#get_filetypes()
    if len(cfts) > 0
      if cfts[0] == 'svelte'
        let cft = 'html'
      elseif cfts[0] == 'scss'
        let cft = 'css'
      else
        let cft = cfts[0]
      endif
      exe 'setf ' . cft
    endif
  endif
endfu
fu! NERDCommenter_after()
  if (g:ft == 'html') || (g:ft == 'svelte') || (g:ft == 'vue')
    exec 'setf ' . g:ft
    let g:ft = ''
  endif
endfu


" -------------------------------------
" .editorconfig support
" -------------------------------------
let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']


" **********************************************************************
" Convenience variables
" **********************************************************************



" **********************************************************************
" GUI-only hacks
" **********************************************************************
if has('nvim')
  " nvim 0.4.2+ gui-only initializer
  function! s:ui_enter()
    if get(v:event, "chan") == 1
      " disable neovim-gtk's tabline
      call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
      " additional info on gui
      let $FZF_DEFAULT_OPTS .= ' --inline-info'
    endif
  endfunction

  au UIEnter * call s:ui_enter()
endif
