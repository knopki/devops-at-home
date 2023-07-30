{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types;
  inherit (lib.generators) toINI;
  cfg = config.programs.imv;
in
{
  options.programs.imv = {
    enable = mkEnableOption "imv configuration";

    package = mkOption {
      default = pkgs.imv;
      type = types.package;
    };


    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      visible = false;
      description = "Resulting imv package.";
    };

    settings = mkOption {
      default = { };
      type = with types; attrsOf (attrsOf (either str bool));
      description = "Configuration; see man 5 imv.";
    };
  };

  config = mkIf cfg.enable {
    programs.imv.finalPackage = cfg.package;
    home.packages = [ cfg.finalPackage ];
    xdg.configFile."imv/config".text = toINI { } cfg.settings;
  };
}
