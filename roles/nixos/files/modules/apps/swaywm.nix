{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.apps.swaywm.enable = mkEnableOption "Enable SwayWM"; };

  config = mkIf config.local.apps.swaywm.enable {
    environment.systemPackages = with pkgs; [ gnome3.dconf-editor ];

    programs = {
      light.enable = true;
      sway = {
        enable = true;
        extraPackages = with pkgs; [
          alacritty
          gnome3.seahorse
          grim
          i3
          i3status
          iw # required by i3status
          libnotify
          libnotify
          mako
          playerctl
          python36Packages.py3status
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

          export SSH_ASKPASS=${pkgs.gnome3.seahorse}/libexec/seahorse/ssh-askpass
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
