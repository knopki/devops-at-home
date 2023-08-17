{pkgs, ...}: let
  inherit (pkgs.sway-contrib) inactive-windows-transparency;
in {
  home.packages = [inactive-windows-transparency];

  systemd.user.services.sway-inactive-windows-transparency = {
    Unit = {
      Description = "Set opacity of onfocused windows in SwayWM";
      PartOf = "graphical-session.target";
      StartLimitIntervalSec = "0";
    };
    Service = {
      Type = "simple";
      ExecStart = ''
        ${inactive-windows-transparency}/bin/inactive-windows-transparency.py -o 0.9
      '';
      Restart = "on-failure";
      RestartSec = "1";
    };
    Install = {WantedBy = ["sway-session.target"];};
  };
}
