{
  lib,
  config,
  inputs,
  self,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkForce mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.lists) optional;
  cfg = config.custom.lanzaboote;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    self.modules.nixos.system-systemd-boot
  ];

  options.custom.lanzaboote = {
    enable = mkEnableOption "Enable lanzaboote profile for Secure Boot";
    debug = mkEnableOption "Enable debug shell. WARNING Provides unauthenticated root access. DELETE all stubs after debugging!";
  };

  config = mkIf cfg.enable {
    warnings = optional cfg.debug "systemIdentity: Debug is enabled. Do not use in production.";

    # Lanzaboote replaces systemd-boot for Secure Boot
    custom.systemd-boot.enable = true;
    boot.loader.systemd-boot.enable = mkForce false;

    boot.lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
      autoEnrollKeys.autoReboot = true;
      pkiBundle = "/var/lib/sbctl";
    };

    environment.systemPackages = [ pkgs.sbctl ];

    # WARNING: rd.systemd.debug_shell provides unauthenticated root access
    boot.kernelParams = mkIf cfg.debug [
      "systemd.log_level=debug"
      "systemd.log_target=console"
    ];
    boot.initrd.systemd.emergencyAccess = mkIf cfg.debug true;
  };
}
