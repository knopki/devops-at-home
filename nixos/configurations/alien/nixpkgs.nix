{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) getName getNameWithVersion;
in
{
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      elem (getName pkg) [
        "anytype"
        "anydesk"
        "corefonts"
        "mpv-thumbfast"
        "pantum-driver"
        "trezor-suite"
        "unrar"
      ];

    allowInsecurePredicate =
      pkg:
      elem (getName pkg) [
        "youtube-dl"
      ];
  };

  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
