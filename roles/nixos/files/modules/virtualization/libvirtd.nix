{ config, lib, ... }:

with lib;
{
  options.local.virtualisation.libvirtd.enable = mkEnableOption "Enable Libvirt";

  config = mkIf config.local.virtualisation.libvirtd.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemuRunAsRoot = true;
    };
  };
}
