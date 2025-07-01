{ lib, self, ... }:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.overlays = [ self.overlays.my-packages ];
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
