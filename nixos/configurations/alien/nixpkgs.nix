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
        "deezer-desktop"
        "discord"
        "edl"
        "mpv-thumbfast"
        "obsidian"
        "pantum-driver"
        "unrar"
      ];

    allowInsecurePredicate =
      pkg:
      elem (getName pkg) [
        "golden-cheetah"
        "youtube-dl"
      ];
  };
}
