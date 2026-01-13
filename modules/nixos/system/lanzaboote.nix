{
  lib,
  config,
  inputs,
  self,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce mkEnableOption mkIf;
  cfg = config.custom.lanzaboote;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    self.modules.nixos.system-systemd-boot
  ];

  options.custom.lanzaboote.enable = mkEnableOption "Enable lanzaboote profile for Secure Boot";

  config = mkIf cfg.enable {
    # Lanzaboote replaces systemd-boot for Secure Boot
    custom.systemd-boot.enable = true;
    boot.loader.systemd-boot.enable = mkForce false;

    # boot.loader.efi.canTouchEfiVariables = true;

    boot.lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
      autoEnrollKeys.autoReboot = true;
      pkiBundle = "/var/lib/sbctl";
    };

    environment.systemPackages = with pkgs; [
      sbctl
    ];
  };
}
