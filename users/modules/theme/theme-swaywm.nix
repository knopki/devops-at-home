{ config, options, lib, ... }:
let
  inherit (lib) mkIf mkMerge mkBefore mkEnableOption elem;
  cfg = config.theme;
in
{
  options.theme.components.swaywm.enable = mkEnableOption "Apply theme to SwayWM" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.swaywm.enable && options ? swayland.windowManager.sway) (mkMerge [
    {
      wayland.windowManager.sway.config.fonts = [
        "${cfg.fonts.regular.family} ${toString cfg.fonts.regular.size}"
      ];
    }

    (mkIf (!elem cfg.preset [ "dracula" ]) {
      wayland.windowManager.sway.config.colors = with cfg.base16.colors; {
        background = mkDefault "#${base07.hex.rgb}";
        focused = {
          border = mkDefault "#${base05.hex.rgb}";
          background = mkDefault "#${base0D.hex.rgb}";
          text = mkDefault "#${base00.hex.rgb}";
          indicator = mkDefault "#${base0D.hex.rgb}";
          childBorder = mkDefault "#${base0D.hex.rgb}";
        };
        focusedInactive = {
          border = mkDefault "#${base01.hex.rgb}";
          background = mkDefault "#${base01.hex.rgb}";
          text = mkDefault "#${base05.hex.rgb}";
          indicator = mkDefault "#${base03.hex.rgb}";
          childBorder = mkDefault "#${base01.hex.rgb}";
        };
        unfocused = {
          border = mkDefault "#${base01.hex.rgb}";
          background = mkDefault "#${base00.hex.rgb}";
          text = mkDefault "#${base05.hex.rgb}";
          indicator = mkDefault "#${base01.hex.rgb}";
          childBorder = mkDefault "#${base01.hex.rgb}";
        };
        urgent = {
          border = mkDefault "#${base08.hex.rgb}";
          background = mkDefault "#${base08.hex.rgb}";
          text = mkDefault "#${base00.hex.rgb}";
          indicator = mkDefault "#${base08.hex.rgb}";
          childBorder = mkDefault "#${base08.hex.rgb}";
        };
        placeholder = {
          border = mkDefault "#${base00.hex.rgb}";
          background = mkDefault "#${base00.hex.rgb}";
          text = mkDefault "#${base05.hex.rgb}";
          indicator = mkDefault "#${base00.hex.rgb}";
          childBorder = mkDefault "#${base00.hex.rgb}";
        };
      };
    })

    (mkIf (cfg.preset == "dracula") {
      # from https://github.com/dracula/i3/blob/master/.config/i3/config
      wayland.windowManager.sway.extraConfig = mkBefore ''
        client.focused          #6272A4 #6272A4 #F8F8F2 #6272A4   #6272A4
        client.focused_inactive #44475A #44475A #F8F8F2 #44475A   #44475A
        client.unfocused        #282A36 #282A36 #BFBFBF #282A36   #282A36
        client.urgent           #44475A #FF5555 #F8F8F2 #FF5555   #FF5555
        client.placeholder      #282A36 #282A36 #F8F8F2 #282A36   #282A36

        client.background       #F8F8F2
      '';
    })
  ]);
}
