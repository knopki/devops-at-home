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
        vim-airline
        vim-airline-themes
        vim-one
        indentLine
        fzf-vim
        nerdtree
        vim-startify
        pkgs.localVimPlugins.vim-bbye
        context_filetype-vim # dep of caw-vim
        caw-vim
        vim-fugitive

        vim-orgmode
        vim-polyglot
      ];

      extraConfig = readFile ./neovim.vim;
    };
  };
}
