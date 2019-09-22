{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.neovim = { enable = mkEnableOption "enable neovim for user"; };

  config = mkIf config.local.neovim.enable {
    #
    # Reference:
    # https://github.com/rycee/home-manager/blob/master/modules/programs/neovim.nix
    #

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        # UI
        nerdtree
        vim-airline

        # Language support
        vim-polyglot
      ];

      extraConfig = ''
        " Put $ at the boundary of current replace
        :set cpoptions+=$

        let g:airline_powerline_fonts = 1
      '';

    };
  };
}
