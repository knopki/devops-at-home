{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.kde.settings.kdeglobals.General = {
    TerminalApplication = mkDefault "alacritty";
    TerminalService = mkDefault "Alacritty.desktop";
  };

  systemd.user.sessionVariables = {
    TERMINAL = mkDefault "alacritty -e";
  };
}
