{ config, pkgs, lib, ... }:
let
  inherit (lib) mkDefault mkBefore concatStringsSep;
  extraOptions = [ "--my-next-gpu-wont-be-nvidia" ];
  extraSessionCommands = ''
    source /etc/profile
    test -f $HOME/.profile && source $HOME/.profile

    # session
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    # wayland enablement
    export MOZ_ENABLE_WAYLAND=1
    export MOZ_DBUS_REMOTE=1
    export CLUTTER_BACKEND=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export ECORE_EVAS_ENGINE=wayland-egl
    export ELM_ENGINE=wayland_egl
    export SDL_VIDEODRIVER=wayland
    export _JAVA_AWT_WM_NONREPARENTING=1
    export NO_AT_BRIDGE=1
    export WLR_DRM_NO_MODIFIERS=1
  '';
in
{
  environment.systemPackages = with pkgs; [
    pavucontrol
    playerctl
  ];

  programs = {
    light.enable = mkDefault true;
    sway = {
      inherit extraSessionCommands extraOptions;
      enable = true;
      extraPackages = with pkgs; [
        qt5.qtwayland # enable Qt5 Wayland support
        swaybg # set wallpaper (very simple)
      ];
      wrapperFeatures.gtk = true;
    };
  };

  services.xserver.xkbOptions = "grp:caps_toggle,grp_led:caps";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}
