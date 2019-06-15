{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.apps.swaywm.enable = mkEnableOption "Enable SwayWM";
  };

  config = mkIf config.local.apps.swaywm.enable {
    environment.systemPackages = with pkgs; [
      gnome3.dconf-editor
    ];

    programs = {
      light.enable = true;
      sway = {
        enable = true;
        extraPackages = with pkgs; [
          grim
          i3status
          libnotify
          libnotify
          mako
          playerctl
          python36Packages.py3status
          rofi
          rofi-pass
          slurp
          swayidle
          swaylock
          termite
          wf-recorder
          wl-clipboard
          xwayland
        ];
        extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          # needs qt5.qtwayland in systemPackages
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          # Fix for some Java AWT applications (e.g. Android Studio),
          # use this if they aren't displayed properly:
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
    };

    services = {
      dbus.packages = with pkgs; [ gnome3.dconf ];
      gnome3.gnome-keyring.enable = true;
      xserver.displayManager.extraSessionFilePackages = [ pkgs.sway ];
    };
  };
}
