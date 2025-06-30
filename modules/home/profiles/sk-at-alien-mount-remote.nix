{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) replaceStrings;
  inherit (lib.strings) removePrefix;
  pathToUnitName =
    x:
    replaceStrings
      [
        "-"
        "/"
      ]
      [
        "\\x2d"
        "-"
      ]
      (removePrefix "/" x);
  remotesRootPath = "${config.home.homeDirectory}/remote";
  skNcMountPath = "${remotesRootPath}/sk-nc";
  skNcCachePath = "${config.xdg.cacheHome}/rclone/sk-nc";
  skNcUnitName = pathToUnitName skNcMountPath;
in
{
  systemd.user.tmpfiles.rules = [
    "d ${skNcCachePath} 0700 - - 30d"
    "d ${skNcMountPath} 0700 - - -"
  ];

  systemd.user.services.${skNcUnitName} = {
    Unit = {
      Description = "mount for ${skNcMountPath}";
      AssertPathIsDirectory = skNcCachePath;
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --cache-dir=${skNcCachePath} --vfs-cache-mode=writes sk_at_nc: ${skNcMountPath}";
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -zu ${skNcMountPath}";
      Restart = "on-failure";
      RestartSec = 15;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
