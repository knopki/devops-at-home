{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  # services.flatpak.enable = true;
  # xdg.portal = {
  #   enable = true;
  # };

  # # Fonts workaround
  # system.fsPackages = [ pkgs.bindfs ];
  # fileSystems =
  #   let
  #     mkRoSymBind = path: {
  #       device = path;
  #       fsType = "fuse.bindfs";
  #       options = [
  #         "ro"
  #         "resolve-symlinks"
  #         "x-gvfs-hide"
  #       ];
  #       noCheck = true;
  #     };
  #     aggregatedFonts = pkgs.buildEnv {
  #       name = "system-fonts";
  #       paths = config.fonts.packages;
  #       pathsToLink = [ "/share/fonts" ];
  #     };
  #   in
  #   {
  #     # Create an FHS mount to support flatpak host icons/fonts
  #     "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
  #     "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  #   };

  # # fix can't open links in system browser
  # systemd.user.extraConfig = ''
  #   DefaultEnvironment="PATH=/run/current-system/sw/bin"
  # '';
}
