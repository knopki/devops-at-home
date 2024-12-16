{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault readFile;
in
{
  home.packages = with pkgs; [ ripgrep ];

  programs.direnv.enable = true;
  programs.fzf.enable = true;

  #
  # Reference:
  # https://github.com/rycee/home-manager/blob/master/modules/programs/neovim.nix
  #
  programs.neovim = {
    enable = mkDefault true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # visual
      {
        plugin = vim-airline;
        config = ''
          let g:airline_highlighting_cache = 1
          let g:airline_skip_empty_sections = 1
          let g:airline_extensions = ['branch', 'tabline']
          let g:airline#extensions#branch#enabled = 1
          let g:airline#extensions#tabline#enabled = 1
        '';
      }
      {
        plugin = indentLine;
        config = ''
          let g:indentLine_enabled = 1
          let g:indentLine_concealcursor = 0
          let g:indentLine_char = '┆'
          let g:indentLine_faster = 1
        '';
      }
      {
        plugin = vim-devicons;
        config = ''
          function! StartifyEntryFormat()
            return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
          endfunction
        '';
      }

      # fuzzy search everything
      {
        plugin = fzf-vim;
        config = ''
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

          autocmd! FileType fzf
          autocmd  FileType fzf set noshowmode noruler nonu

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
        '';
      }

      # filemanager
      {
        plugin = nerdtree;
        config = ''
          nnoremap <silent> <leader>n :NERDTreeToggle<cr>

          let g:NERDTreeChDirMode = 2
          let g:NERDTreeIgnore=['\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
          let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
          let g:NERDTreeShowBookmarks = 1
        '';
      }

      # session management and more
      {
        plugin = vim-startify;
        config = ''
          nnoremap <leader>so :SLoad<CR>
          nnoremap <leader>ss :SSave!<CR>
          nnoremap <leader>sd :SDelete<CR>
          nnoremap <leader>sc :SClose<CR>

          let g:startify_bookmarks = ['~/dev/knopki/devops-at-home']
          let g:startify_session_persistence = 1
          let g:startify_change_to_vcs_root = 1
          let g:startify_session_sort = 1
          let g:startify_custom_header = []
          let g:startify_skip_list = ['COMMIT_MSG', '/nit/store/*']
        '';
      }

      # git stuff
      {
        plugin = vim-fugitive;
        config = ''
          if exists("*fugitive#statusline")
            set statusline+=%{fugitive#statusline()}
          endif
        '';
      }
      vim-gitgutter

      # support .editorconfig
      {
        plugin = editorconfig-vim;
        config = ''
          let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']
        '';
      }

      # undo tree vizualizer
      {
        plugin = undotree;
        config = ''
          nnoremap <leader>ut :UndotreeToggle<CR>
        '';
      }

      # commenting
      {
        # context-aware filetype for nerdcommenter
        plugin = context_filetype-vim;
        config = ''
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
        '';
      }
      {
        plugin = nerdcommenter;
        config = ''
          let g:NERDDefaultAlign = 'left'
          let g:NERDSpaceDelims = 1
          let g:NERDCommentEmpryLines = 1
          let g:NERDTrimTrailingWhitespace = 1
          let g:NERDToggleCheckAllLines = 1
          let g:ft = '''
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
              let g:ft = '''
            endif
          endfu
        '';
      }

      # load envrc
      direnv-vim

      {
        plugin = ultisnips;
        config = ''
          let g:UltiSnipsExpandTrigger="<tab>"
          let g:UltiSnipsJumpForwardTrigger="<tab>"
          let g:UltiSnipsJumpBackwardTrigger="<c-b>"
          let g:UltiSnipsEditSplit="vertical"
        '';
      }
      vim-snippets
      vim-surround

      vim-polyglot
    ];

    extraConfig = mkDefault (readFile ./neovim.vim);
  };
}
