{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    elem (getName pkg) [
      "anytype"
      "anydesk"
      "corefonts"
      "mpv-thumbfast"
      "pantum-driver"
      "trezor-suite-24.1.2"
      "unrar"
    ];

  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
