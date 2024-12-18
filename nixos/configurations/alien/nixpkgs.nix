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
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      elem (getName pkg) [
        "anydesk"
        "anytype"
        "aspell-dict-en-science"
        "corefonts"
        "discord"
        "edl"
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
}
