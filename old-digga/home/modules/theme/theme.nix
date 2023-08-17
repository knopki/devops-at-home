{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.theme;
in {
  options.theme = {
    enable = mkEnableOption "Enable theme support";

    preset = mkOption {
      type = with types; nullOr (enum ["dracula"]);
      default = null;
      description = "Apply one of predefined presets.";
    };
  };

  config = mkIf cfg.enable {};
}
