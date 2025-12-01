{ config, lib, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.profiles.no-docs;
in
{
  options.profiles.no-docs.enable = mkEnableOption "Enable no documentation profile";

  config = mkIf cfg.enable {
    documentation = {
      # Notice this also disables --help for some commands such as nixos-rebuild
      enable = mkDefault false;
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };
  };
}
