_final: prev:
let
  inherit (prev.lib.strings) compareVersions getVersion;
  pkgIfVersionMin =
    pkg: minVer: altPkg:
    if (compareVersions (getVersion pkg) minVer) >= 0 then pkg else altPkg;
  p = prev.nixpkgsUnstable;
in
{
  act = pkgIfVersionMin prev.act "0.2.81" p.act;

  affine = pkgIfVersionMin prev.affine "0.24" p.affine;

  anytype =
    let
      unstableAnytype = prev.callPackage p.anytype.override {
        anytype-heart = p.anytype-heart;
      };
    in
    pkgIfVersionMin prev.anytype "0.49.2" unstableAnytype;

  lima = pkgIfVersionMin prev.lima "1.2" p.lima;

  naps2 =
    let
      unstableNaps2 = prev.callPackage p.naps2.override { };
    in
    pkgIfVersionMin prev.anytype "8.2.1" unstableNaps2;

  # not in 25.05
  plakar = prev.callPackage p.plakar.override { };

  simplex-chat-desktop =
    let
      unstableSimplexChat = prev.callPackage p.simplex-chat-desktop.override { };
    in
    pkgIfVersionMin prev.simplex-chat-desktop "6.4" unstableSimplexChat;

  siyuan = pkgIfVersionMin prev.siyuan "3.3" p.siyuan;

  zed-editor = pkgIfVersionMin prev.zed-editor "0.204" p.zed-editor;
}
