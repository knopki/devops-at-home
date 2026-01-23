{ lib, config, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.custom.systemd-boot;
in
{
  options.custom.systemd-boot.enable = mkEnableOption "Enable systemd-boot profile";

  config = mkIf cfg.enable {
    boot.loader = {
      # enable but do not force
      systemd-boot.enable = mkDefault true;

      # Use systemd-boot to boot EFI machines
      systemd-boot.configurationLimit = lib.mkOverride 1337 20;
      timeout = mkDefault 3;
    };
  };
}
