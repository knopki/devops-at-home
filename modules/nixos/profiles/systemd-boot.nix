{ lib, config, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.profiles.systemd-boot;
in
{
  options.profiles.systemd-boot.enable = mkEnableOption "Enable systemd-boot profile";

  config = mkIf cfg.enable {
    # Use systemd-boot to boot EFI machines
    boot.loader.systemd-boot.configurationLimit = lib.mkOverride 1337 10;
    boot.loader.systemd-boot.enable = true;
    boot.loader.timeout = mkDefault 3;
  };
}
