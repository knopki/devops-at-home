{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.apps.zsh.enable = mkEnableOption "ZSH Options";
  };

  config = mkIf config.local.apps.zsh.enable {
    # install all completions libraries for system packages
    environment.pathsToLink = [ "/share/zsh" ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };
  };
}
