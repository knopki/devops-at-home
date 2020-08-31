{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.starship.enable = mkEnableOption "enable starship configuration";

  config = mkIf config.knopki.starship.enable {
    programs.starship = {
      enable = true;
      settings = {
        character.symbol = "➜";
        conda.disabled = true;
        crystal.disabled = true;
        direcrory.fish_style_pwd_dir_length = 1;
        elixir.disabled = true;
        elm.disabled = true;
        nim.disabled = true;
        purescript.disabled = true;
        zig.disabled = true;
      };
    };
  };
}
