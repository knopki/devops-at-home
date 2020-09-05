{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.knopki.swaywm.enable {
    programs.mako = {
      enable = true;
      sort = "-priority";
      font = "pango:Noto Sans 10";
      borderRadius = 5;
      ## Base16 OneDark / Author: Lalit Magant (http://github.com/tilal6991)
      backgroundColor = "#282c34";
      textColor = "#abb2bf";
      borderColor = "#61afef";
    };

    xdg.configFile."mako/config".text = mkAfter ''
      [urgency=low]
      background-color=#282c34
      text-color=#e5c07b
      border-color=#61afef

      [urgency=high]
      background-color=#282c34
      text-color=#e06c75
      border-color=#61afef
    '';

    systemd.user.services = {
      mako = {
        Unit = {
          Description = "A lightweight Wayland notification daemon";
          Documentation = "man:mako(1)";
          PartOf = "graphical-session.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.mako}/bin/mako";
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };
    };
  };
}
