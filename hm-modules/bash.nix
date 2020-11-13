{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.bash = {
    enable = mkEnableOption "bash configuration";
  };

  config = mkIf config.knopki.bash.enable {
    programs = {
      bash.enable = true;
    };
  };
}
