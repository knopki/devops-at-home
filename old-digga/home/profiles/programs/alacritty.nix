{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.alacritty = {
    enable = mkDefault true;
    settings = {
      key_bindings = [
        # spawn a new instance of Alacritty in the current working directory
        { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
      ];
      window = {
        opacity = 0.95;
      };
    };
  };
}
