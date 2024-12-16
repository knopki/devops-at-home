{
  config,
  lib,
  pkgs,
  packages,
  ...
}: let
  inherit (lib) mkEnableOption mkBefore mkIf concatStrings mapAttrsToList;
  cfg = config.theme;
  template = "${packages.base16-tmux}/templates/base16.mustache";
  themeFile = pkgs.runCommandLocal "hm-tmux-theme" {} ''
    sed '${
      concatStrings
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/;") cfg.base16.colors)
    }' ${template} > $out
  '';
in {
  options.theme.components.tmux.enable = mkEnableOption "Apply theme to tmux" // {default = cfg.enable;};

  config = mkIf (cfg.enable && cfg.components.tmux.enable) {
    programs.tmux.extraConfig = mkBefore ''
      source-file ${themeFile}
    '';
  };
}
