{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  programs.starship = {
    enable = mkDefault true;
    settings = {
      aws.disabled = mkDefault true;
      conda.disabled = mkDefault true;
      crystal.disabled = mkDefault true;
      directory = {
        truncation_length = mkDefault 2;
        fish_style_pwd_dir_length = mkDefault 2;
      };
      elixir.disabled = mkDefault true;
      elm.disabled = mkDefault true;
      gcloud.disabled = mkDefault true;
      nim.disabled = mkDefault true;
      kubernetes.disabled = mkDefault true;
      purescript.disabled = mkDefault true;
      zig.disabled = mkDefault true;
    };
  };
}
