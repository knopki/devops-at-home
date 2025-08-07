{ lib, self, ... }:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.overlays = with self.overlays; [
    anytype-unstable
    simplex-chat-desktop-unstable
    mpv
  ];
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      elem (getName pkg) [
        "anydesk"
        "anytype"
        "anytype-heart"
        "aspell-dict-en-science"
        "corefonts"
        "discord"
        "mpv-thumbfast"
        "obsidian"
        "pantum-driver"
        "terraform"
        "unrar"
      ];

    allowInsecurePredicate =
      pkg:
      elem (getName pkg) [
        "youtube-dl"
      ];
  };
}
