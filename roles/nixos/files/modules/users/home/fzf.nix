{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.fzf = {
    enable = mkEnableOption "enable fzf for user";
  };

  config = mkIf config.local.fzf.enable {
    home.packages = with pkgs; [ fzf ];

    programs.fzf = {
      enable = true;
      defaultOptions = [ "--color=dark" ];
    };
  };
}
