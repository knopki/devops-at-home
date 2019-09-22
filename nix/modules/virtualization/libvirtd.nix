{ config, lib, pkgs, ... }:

with lib; {
  options.local.virtualisation.libvirtd.enable =
    mkEnableOption "Enable Libvirt";

  config = mkIf config.local.virtualisation.libvirtd.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemuRunAsRoot = true;
    };

    environment.systemPackages =
      mkIf config.local.roles.workstation.enable [ pkgs.virtmanager ];
  };
}
