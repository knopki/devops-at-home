{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.qt.enable = mkEnableOption "setup qt";

  config = mkIf config.knopki.qt.enable {
    home.file = {
      "${config.xdg.configHome}/qt5ct/qt5ct.conf".text = generators.toINI {} {
        "Appearance" = {
          custom_palette = false;
          icon_theme = "Adwaita";
          standard_dialogs = "gtk3";
          style = "Adwaita";
        };
        "Fonts" = {
          # Cantarell 11
          general =
            "@Variant(\\0\\0\\0@\\0\\0\\0\\x12\\0\\x43\\0\\x61\\0n\\0t\\0\\x61\\0r\\0\\x65\\0l\\0l@&\\0\\0\\0\\0\\0\\0\\xff\\xff\\xff\\xff\\x5\\x1\\0\\x32\\x10)";
          # Monospaced 11
          fixed =
            "@Variant(\\0\\0\\0@\\0\\0\\0\\x12\\0M\\0o\\0n\\0o\\0s\\0p\\0\\x61\\0\\x63\\0\\x65@&\\0\\0\\0\\0\\0\\0\\xff\\xff\\xff\\xff\\x5\\x1\\0\\x32\\x10)";
        };
      };
    };

    systemd.user.sessionVariables = {
      QT_QPA_PLATFORM = "wayland-egl";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };
}
