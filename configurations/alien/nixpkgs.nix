{ lib, self, ... }:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.overlays = with self.overlays; [
    unstable-backports
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
      elem (lib.debug.traceVal "${pkg.pname}-${pkg.version}") [
      ];
  };
}
