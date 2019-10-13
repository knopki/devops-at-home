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

        vim-orgmode
        vim-polyglot
        pkgs.localVimPlugins.vim-bbye
        # pkgs.localVimPlugins.xolox-vim-misc
        # pkgs.localVimPlugins.vim-session
      ];

      extraConfig = readFile ./neovim.vim;
    };
  };
}
