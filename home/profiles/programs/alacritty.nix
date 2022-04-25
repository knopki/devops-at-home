{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.alacritty = {
    enable = mkDefault true;
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
}
