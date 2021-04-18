{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      background_opacity = 0.95;
      env = {
        # fix scaling on X11
        WINIT_X11_SCALE_FACTOR = "1";
      };
      key_bindings = [
        # spawn a new instance of Alacritty in the current working directory
        { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
      ];
    };
  };

  programs.kde.settings.kdeglobals.General = {
    TerminalApplication = mkDefault "alacritty";
    TerminalService = mkDefault "Alacritty.desktop";
  };

  systemd.user.sessionVariables = {
    TERMINAL = mkDefault "alacritty -e";
  };
}
