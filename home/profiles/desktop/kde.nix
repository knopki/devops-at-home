{ config, nixosConfig, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf;
in
{
  home.packages =
    with pkgs;
    with plasma5Packages;
    with plasma5;
    with kdeApplications;
    with kdeFrameworks;
    [
      bismuth
      kwinscript-window-colors
      plasma-applet-caffeine-plus
      plasma-applet-virtual-desktop-bar
    ];

  programs = {
    kde = {
      enable = mkDefault true;
      settings = {
        kdeglobals.KDE.SingleClick = mkDefault false;

        kxkbrc.Layout = {
          ResetOldOptions = mkDefault true;
          SwitchMode = mkDefault "Window";
          Use = mkDefault true;
        };
      };
    };
  };

  systemd.user.targets.tray = mkIf config.programs.kde.enable {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
