{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.bash = {
    enable = mkEnableOption "bash configuration";
  };

  config = mkIf config.knopki.bash.enable {
    knopki.fzf.enable = true;
    programs = {
      bash.enable = true;
      fzf.enableBashIntegration = true;
      dircolors.enableBashIntegration = true;
      direnv.enableBashIntegration = true;
    };
  };
}
