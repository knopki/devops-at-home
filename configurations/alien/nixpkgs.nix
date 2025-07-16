{ lib, self, ... }:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.overlays = with self.overlays; [
    nixpkgs-unstable
    anytype-unstable
    lima-unstable
    simplex-chat-desktop-unstable
    zed-editor-unstable
    mpv
    my-packages
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
        "golden-cheetah"
        "youtube-dl"
      ];
  };
}
