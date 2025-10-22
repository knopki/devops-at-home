_final: prev:
let
  inherit (prev.lib.strings) compareVersions getVersion;
  pkgIfVersionMin =
    pkg: minVer: altPkg:
    if (compareVersions (getVersion pkg) minVer) >= 0 then pkg else altPkg;
  p = prev.nixpkgsUnstable;
in
{
  affine = pkgIfVersionMin prev.affine "0.24" p.affine;

  anytype =
    let
      unstableAnytype = prev.callPackage p.anytype.override {
        anytype-heart = p.anytype-heart;
      };
    in
    pkgIfVersionMin prev.anytype "0.50.5" unstableAnytype;

  bees = pkgIfVersionMin prev.bees "0.11" p.bees;

  cosmic-applets = pkgIfVersionMin prev.cosmic-applets "1.0.0-beta.1.1" p.cosmic-applets;

  cosmic-applibrary = pkgIfVersionMin prev.cosmic-applibrary "1.0.0-beta.1.1" p.cosmic-applibrary;

  cosmic-bg = pkgIfVersionMin prev.cosmic-bg "1.0.0-beta.1.1" p.cosmic-bg;

  cosmic-comp = pkgIfVersionMin prev.cosmic-comp "1.0.0-beta.1.1" p.cosmic-comp;

  cosmic-edit = pkgIfVersionMin prev.cosmic-edit "1.0.0-beta.1.1" p.cosmic-edit;

  cosmic-ext-tweaks = pkgIfVersionMin prev.cosmic-ext-tweaks "0.2.0" p.cosmic-ext-tweaks;

  cosmic-files = pkgIfVersionMin prev.cosmic-files "1.0.0-beta.1.1" p.cosmic-files;

  cosmic-greeter = pkgIfVersionMin prev.cosmic-greeter "1.0.0-beta.1.1" p.cosmic-greeter;

  cosmic-icons = pkgIfVersionMin prev.cosmic-icons "1.0.0-beta.1.1" p.cosmic-icons;

  cosmic-idle = pkgIfVersionMin prev.cosmic-idle "1.0.0-beta.1.1" p.cosmic-idle;

  cosmic-launcher = pkgIfVersionMin prev.cosmic-launcher "1.0.0-beta.1.1" p.cosmic-launcher;

  cosmic-notifications =
    pkgIfVersionMin prev.cosmic-notifications "1.0.0-beta.1.1"
      p.cosmic-notifications;

  cosmic-osd = pkgIfVersionMin prev.cosmic-osd "1.0.0-beta.1.1" p.cosmic-osd;

  cosmic-panel = pkgIfVersionMin prev.cosmic-panel "1.0.0-beta.1.1" p.cosmic-panel;

  cosmic-player = pkgIfVersionMin prev.cosmic-player "1.0.0-beta.1.1" p.cosmic-player;

  cosmic-randr = pkgIfVersionMin prev.cosmic-randr "1.0.0-beta.1.1" p.cosmic-randr;

  cosmic-screenshot = pkgIfVersionMin prev.cosmic-screenshot "1.0.0-beta.1.1" p.cosmic-screenshot;

  cosmic-session = pkgIfVersionMin prev.cosmic-session "1.0.0-beta.1.1" p.cosmic-session;

  cosmic-settings = pkgIfVersionMin prev.cosmic-settings "1.0.0-beta.1.1" p.cosmic-settings;

  cosmic-settings-daemon =
    pkgIfVersionMin prev.cosmic-settings-daemon "1.0.0-beta.1.1"
      p.cosmic-settings-daemon;

  cosmic-term = pkgIfVersionMin prev.cosmic-term "1.0.0-beta.1.1" p.cosmic-term;

  cosmic-wallpapers = pkgIfVersionMin prev.cosmic-wallpapers "1.0.0-beta.1.1" p.cosmic-wallpapers;

  cosmic-workspaces-epoch =
    pkgIfVersionMin prev.cosmic-workspaces-epoch "1.0.0-beta.1.1"
      p.cosmic-workspaces-epoch;

  devenv = pkgIfVersionMin prev.devenv "1.10" p.devenv;

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

  xdg-desktop-portal-cosmic =
    pkgIfVersionMin prev.xdg-desktop-portal-cosmic "1.0.0-beta.1.1"
      p.xdg-desktop-portal-cosmic;

  zed-editor = pkgIfVersionMin prev.zed-editor "0.204" p.zed-editor;
}
