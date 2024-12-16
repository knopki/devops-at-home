{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.theme;
in {
  options.theme.components.fzf.enable = mkEnableOption "Apply theme to fzf" // {default = cfg.enable;};

  config = mkIf (cfg.enable && cfg.components.fzf.enable) {
    programs.fzf.defaultOptions = with cfg.base16.colors; [
      "--color=bg+:#${base01.hex.rgb},bg:#${base00.hex.rgb},spinner:#${base0C.hex.rgb},hl:#${base0D.hex.rgb}"
      "--color=fg:#${base04.hex.rgb},header:#${base0D.hex.rgb},info:#${base0A.hex.rgb},pointer:#${base0C.hex.rgb}"
      "--color=marker:#${base0C.hex.rgb},fg+:#${base06.hex.rgb},prompt:#${base0A.hex.rgb},hl+:#${base0D.hex.rgb}"
    ];
  };
}
