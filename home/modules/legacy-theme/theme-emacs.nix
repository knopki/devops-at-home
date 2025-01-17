{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkBefore
    mkIf
    optionalString
    ;
  cfg = config.theme;
  base16colors = with cfg.base16.colors; ''
    (defvar base16-theme-name "${cfg.base16.name}")
    (defvar base16-theme-kind "${cfg.base16.kind}")
    (defvar base16-colors
      '(:base00 "#${base00.hex.rgb}"
        :base01 "#${base01.hex.rgb}"
        :base02 "#${base02.hex.rgb}"
        :base03 "#${base03.hex.rgb}"
        :base04 "#${base04.hex.rgb}"
        :base05 "#${base05.hex.rgb}"
        :base06 "#${base06.hex.rgb}"
        :base07 "#${base07.hex.rgb}"
        :base08 "#${base08.hex.rgb}"
        :base09 "#${base09.hex.rgb}"
        :base0A "#${base0A.hex.rgb}"
        :base0B "#${base0B.hex.rgb}"
        :base0C "#${base0C.hex.rgb}"
        :base0D "#${base0D.hex.rgb}"
        :base0E "#${base0E.hex.rgb}"
        :base0F "#${base0F.hex.rgb}")
      "All colors for Base16 {{scheme-name}} are defined here.")
  '';
in
{
  options.theme.components.emacs.enable = mkEnableOption "Apply theme to Doom Emacs" // {
    default = cfg.enable;
  };

  config = mkIf (cfg.enable && cfg.components.emacs.enable) {
    programs.emacs.extraConfig = mkBefore ''
      ${base16colors}

      (setq doom-font (font-spec :family "${cfg.fonts.monospace.family}"
                                 :size ${toString (cfg.fonts.monospace.size + 6)})
            doom-variable-pitch-font (font-spec :family "${cfg.fonts.document.family}"))

      ${optionalString (cfg.preset == "dracula") "(setq doom-theme 'doom-dracula)"}
    '';
  };
}
