{ lib, config, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.custom.systemd-boot;
in
{
  options.custom.systemd-boot.enable = mkEnableOption "Enable systemd-boot profile";

  config = mkIf cfg.enable {
    # enable but do not force
    boot.loader.systemd-boot.enable = mkDefault true;

    # Use systemd-boot to boot EFI machines
    boot.loader.systemd-boot.configurationLimit = lib.mkOverride 1337 10;
    boot.loader.timeout = mkDefault 3;
  };
}
