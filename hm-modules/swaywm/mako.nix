{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.knopki.swaywm.enable {
    programs.mako = {
      enable = true;
      sort = "-priority";
      font = "pango:Noto Sans 10";
      ## Base16 OneDark / Author: Lalit Magant (http://github.com/tilal6991)
      backgroundColor = "#3e4451";
      textColor = "#abb2bf";
      borderColor = "#abb2bf";
    };

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
