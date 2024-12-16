{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    ./_disko.nix
  ];
  config = {
    boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
    boot.loader.systemd-boot.enable = true;
    boot.kernelParams = [ "nohibernate" ];
    boot.zfs.extraPools = [ "tank" ];
    services.zfs.autoScrub.enable = true;
    services.zfs.trim.enable = true;
    #boot.initrd.postDeviceCommands = lib.mkAfter ''
    #  zfs rollback -r tank/local/root@blank
    #'';
  };
}
