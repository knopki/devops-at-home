{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.neovim = { enable = mkEnableOption "enable neovim for user"; };

  config = mkIf config.local.neovim.enable {
    home.packages = with pkgs; [ ripgrep ];
    local.fzf.enable = true;

    #
    # Reference:
    # https://github.com/rycee/home-manager/blob/master/modules/programs/neovim.nix
    #
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        # visual
        vim-airline
        vim-airline-themes
        vim-one
        indentLine
        vim-devicons

        # fuzzt search everything
        fzf-vim
        # filemanager
        nerdtree

        # session management and more
        vim-startify

        # don't close window with buffer
        pkgs.localVimPlugins.vim-bbye

        # git stuff
        vim-fugitive
        vim-rhubarb # open file on github
        vim-gitgutter

        # support .editorconfig
        editorconfig-vim

        # undo tree vizualizer
        undotree

        # commenting
        context_filetype-vim # context-aware filetype for nerdcommenter
        nerdcommenter

        # load envrc
        direnv-vim

        ultisnips
        vim-snippets
        pkgs.localVimPlugins.vim-sideways
        vim-surround

        vim-orgmode
        vim-polyglot
      ];

      extraConfig = readFile ./neovim.vim;
    };
  };
}
