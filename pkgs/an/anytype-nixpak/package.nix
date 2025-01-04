# TODO: not completed
{
  lib,
  pkgs,
  mkNixPakPackage,
  ...
}:
mkNixPakPackage {
  config =
    { sloth, ... }:
    rec {
      app.package = pkgs.callPackage ../anytype/package.nix { };
      bubblewrap = {
        bind.rw = [
          (sloth.concat' sloth.xdgCacheHome "/fontconfig")
          (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
          (sloth.concat' sloth.runtimeDir "/at-spi/bus")
          (sloth.concat' sloth.runtimeDir "/gvfsd")
          (sloth.concat' sloth.xdgConfigHome "anytype")
          (sloth.concat' sloth.xdgDataHome "anytype")
        ];
        bind.ro = [
          (sloth.concat' sloth.runtimeDir "/doc")
          (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
          (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
          (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
          (sloth.concat' sloth.xdgConfigHome "/fontconfig")
        ];
        env = {
          XDG_DATA_DIRS = lib.makeSearchPath "share" [
            pkgs.adwaita-icon-theme
            pkgs.shared-mime-info
          ];
          XCURSOR_PATH = lib.concatStringsSep ":" [
            "${pkgs.adwaita-icon-theme}/share/icons"
            "${pkgs.adwaita-icon-theme}/share/pixmaps"
          ];
        };
        sockets = {
          pulse = true;
          pipewire = true;
          x11 = true;
          wayland = true;
        };
        shareIpc = true;
        network = true;
      };
      flatpak.appId = "io.anytype.Anytype";
      dbus = {
        enable = true;
        policies = {
          "${flatpak.appId}" = "own";
          "org.freedesktop.DBus" = "talk";
          "org.gtk.vfs.*" = "talk";
          "org.gtk.vfs" = "talk";
          "ca.desrt.dconf" = "talk";
          "org.freedesktop.portal.*" = "talk";
          "org.a11y.Bus" = "talk";
          "org.freedesktop.secrets" = "talk";
          "org.kde.StatusNotifierWatcher" = "talk";
        };
      };
      fonts.enable = true;
      gpu.enable = true;
      gpu.provider = "bundle";
      locale.enable = true;
      etc.sslCertificates.enable = true;
    };
}
