{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.workstation.enable = mkEnableOption "Workstation Role";
  };

  config = mkIf config.local.roles.workstation.enable {
    local = {
      apps = {
        gnome.enable = true;
        swaywm.enable = true;
        xserver.enable = true;
        zsh.enable = true;
      };

      general = {
        fonts.enable = true;
      };

      hardware = {
        sound.enable = true;
      };

      roles = {
        # "inherit" from `essential` role
        essential.enable = true;
      };

      services = {
        earlyoom.enable = true;
        printing.enable = true;
      };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
      };
    };
  };
}
