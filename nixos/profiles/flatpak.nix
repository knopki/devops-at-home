{ pkgs, lib, inputs, config, ... }:
let
  inherit (lib) mkDefault;
  commonFlatpakUpdateService = {
    description = "Update system Flatpaks";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.flatpak}/bin/flatpak --system update --noninteractive --assumeyes";
    };
  };
  commonFlatpakUpdateTimer = {
    description = "Update Flatpaks";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
in
{
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
  };

  systemd = {
    services.flatpak-update = commonFlatpakUpdateService;
    timers.flatpak-update = commonFlatpakUpdateTimer;

    user = {
      services.flatpak-update = commonFlatpakUpdateService // {
        description = "Update user Flatpaks";
        serviceConfig.ExecStart = "${pkgs.flatpak}/bin/flatpak --user update --noninteractive --assumeyes";
      };
      timers.flatpak-update = commonFlatpakUpdateTimer;
    };
  };

  # Fonts workaround
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.fonts;
      pathsToLink = [ "/share/fonts" ];
    };
  in {
    # Create an FHS mount to support flatpak host icons/fonts
    "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
    "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  };

}
