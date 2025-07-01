{ lib, self, ... }:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.overlays = with self.overlays; [
    nixpkgs-25-05
    anytype-25-05
    aider-chat-25-05
    amneziawg-tools-25-05
    nixpkgs-unstable
    lima-unstable
    zed-editor-unstable
    firefox
    my-packages
  ];
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      elem (getName pkg) [
        "anydesk"
        "anytype"
        "aspell-dict-en-science"
        "corefonts"
        "discord"
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
